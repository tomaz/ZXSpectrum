//
//  Created by Tomaz Kragelj on 11.09.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

/**
Manages file download.
*/
class DownloadFileViewController: UIViewController {
	
	@IBOutlet fileprivate weak var urlTextField: UITextField!
	@IBOutlet fileprivate weak var downloadProgress: UIProgressView!
	@IBOutlet fileprivate weak var downloadButton: UIButton!
	@IBOutlet fileprivate weak var cancelButton: UIButton!

	// MARK: - Signals
	
	fileprivate let url = Property<URL?>(nil)
	fileprivate let progress = Property<Float>(0.0)
	fileprivate let isValidURL = Property(true)
	fileprivate let isDownloading = Property(false)

	// MARK: - Dependencies
	
	fileprivate var fileChangeHandler: FileChangeHandler?

	// MARK: - Data
	
	fileprivate var task: URLSessionDownloadTask? = nil
	
	fileprivate lazy var session: URLSession = {
		return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
	}()

	// MARK: - Overriden functions
	
	override func viewDidLoad() {
		gverbose("Loading")
		
		super.viewDidLoad()

		setupUrlTextSignal()
		setupDownloadButtonTapSignal()
		setupDownloadProgressSignal()
		setupActionSignals()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		gdebug("Dissapearing")

		super.viewWillDisappear(animated)
		
		if let task = task {
			gverbose("Cancelling download")
			task.cancel()
		}
	}
}

// MARK: - Dependencies

extension DownloadFileViewController: FileChangeHandlerConsumer {
	
	func configure(fileChangeHandler: @escaping FileChangeHandler) {
		gdebug("Configuring with file change handler \(fileChangeHandler)")
		self.fileChangeHandler = fileChangeHandler
	}
}

// MARK: - URLSessionDelegate & URLSessionDownloadDelegate

extension DownloadFileViewController: URLSessionDownloadDelegate {
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		gdebug("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite)")

		DispatchQueue.main.async {
			self.progress.value = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		gverbose("Download completed, processing \(location)!")

		do {
			gdebug("Moving downloaded file")
			
			try Database.moveDownloadedFile(from: location, source: url.value)
		} catch {
			gwarn("Failed moving downloaded file \(error)")
			
			DispatchQueue.main.async {
				self.present(error: NSError.download(error: error))
				self.isDownloading.value = false
			}
			return
		}

		gdebug("Download succesfully completed");
		 
		DispatchQueue.main.async {
			self.isDownloading.value = false
			self.fileChangeHandler?()
		}
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			gwarn("Download failed \(String(describing: error))")
			
			DispatchQueue.main.async {
				self.present(error: NSError.download(error: error))
				self.isDownloading.value = false
			}
			return
		}
		
		gdebug("Updating UI after download")
		
		DispatchQueue.main.async {
			self.isDownloading.value = false
		}
	}
}

// MARK: - Helper functions

extension DownloadFileViewController {
	
	fileprivate func isValid(url: String) -> Bool {
		guard url.characters.count > 0 else {
			return false
		}
		
		do {
			let types = NSTextCheckingResult.CheckingType.link
			let detector = try NSDataDetector(types: types.rawValue)
			
			let range = NSRange(location: 0, length: url.characters.count)
			let matches = detector.numberOfMatches(in: url, options: [], range: range)
			return matches > 0
		} catch {
		}
		
		return false
	}

	fileprivate func startDownload() {
		guard let website = url.value else {
			fatalError("`url` must be assigned before downloading!")
		}
		
		if let task = task {
			gdebug("Cancelling existing download")
			task.cancel()
		}
		
		progress.value = 0
		isDownloading.value = true

		task = session.downloadTask(with: website)
		task?.resume()
	}
}

// MARK: - Signals handling

extension DownloadFileViewController {
	
	fileprivate func setupUrlTextSignal() {
		urlTextField.reactive.text.map { $0 ?? "" }.bind(to: self) { me, value in
			gverbose("Changing URL to \(value)")
			let valid = me.isValid(url: value)
			let url = valid ? URL(string: value) : nil
			me.isValidURL.value = url != nil
			me.url.value = url
		}
	}
	
	fileprivate func setupDownloadButtonTapSignal() {
		downloadButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Starting download")
			me.startDownload()
		}
	}
	
	fileprivate func setupDownloadProgressSignal() {
		progress.bind(to: downloadProgress.reactive.progress)
	}
	
	fileprivate func setupActionSignals() {
		let isEditing = isDownloading.map { !$0 }
		
		let canDownload = combineLatest(isDownloading, isValidURL) { downloading, valid in
			return !downloading && valid
		}

		isEditing.bind(to: urlTextField.reactive.isEnabled)
		isEditing.bind(to: downloadProgress.reactive.isHidden)
		isEditing.bind(to: cancelButton.reactive.isHidden)

		canDownload.bind(to: downloadButton.reactive.isEnabled)
	}
}

// MARK: - Declarations

extension DownloadFileViewController {
}
