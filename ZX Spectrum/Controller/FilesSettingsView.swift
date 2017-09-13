//
//  Created by Tomaz Kragelj on 9.06.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

/**
Manages settings for files list.

Note this view subclasses `UIRefreshControl` so we can insert it into table view directly.
*/
final class FilesSettingsView: UIRefreshControl {
	
	fileprivate var deleteSnapshotsButton: UIButton!
	
	// MARK: - Initialization & disposal
	
	override convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	private func initializeView() {
		// Hide default subviews.
		tintColor = .clear
		backgroundColor = .clear
		
		// Setup our custom view hierarchy.
		let stackView = setupContainerStackView()
		setupSortLabel(in: stackView)
		setupSortSegmentedControl(in: stackView)
		setupDelimiterView(in: stackView)
		deleteSnapshotsButton = setupDeleteAllSnapshotsButton(in: stackView)
		
		// Setup signals.
		setupTotalSnapshotSizeSignal()
		setupTotalSignalsButtonTapSignal()
	}
}

// MARK: - Setup

extension FilesSettingsView {
	
	@discardableResult
	fileprivate func setupContainerStackView() -> UIStackView {
		let result = UIStackView()
		result.axis = .horizontal
		result.spacing = 8
		result.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(result)
		result.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		result.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		result.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
		result.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
		
		return result
	}
	
	@discardableResult
	fileprivate func setupSortLabel(in stackView: UIStackView) -> UILabel {
		let result = UILabel()
		result.text = NSLocalizedString("Sort By")
		result.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
		result.translatesAutoresizingMaskIntoConstraints = false
		
		stackView.addArrangedSubview(result)
		
		return result
	}
	
	@discardableResult
	fileprivate func setupSortSegmentedControl(in stackView: UIStackView) -> UISegmentedControl {
		let result = UISegmentedControl(items: FileSortOption.all.map { $0.title })
		result.selectedSegmentIndex = UserDefaults.standard.filesSortOption.rawValue
		
		result.reactive.controlEvents(.valueChanged).bind(to: self) { me, _ in
			let option = FileSortOption(rawValue: result.selectedSegmentIndex)!
			ginfo("Sort option changed \(option)")
			after(0.2) { me.endRefreshing() }
			UserDefaults.standard.filesSortOption = option
		}
		
		stackView.addArrangedSubview(result)
		
		return result
	}
	
	@discardableResult
	fileprivate func setupDelimiterView(in stackView: UIStackView) -> UIView {
		let result = UIView()
		
		stackView.addArrangedSubview(result)
		
		result.widthAnchor.constraint(equalToConstant: 20).isActive = true
		
		return result
	}
	
	@discardableResult
	fileprivate func setupDeleteAllSnapshotsButton(in stackView: UIStackView) -> UIButton {
		let result = UIButton()
		result.attributedTitle = deleteSnapshotsText()
		result.isHidden = result.attributedTitle == nil
		result.image = IconsStyleKit.imageOfIconTrashSnapshot
		result.tintColor = Styles.Appearance.warning.fontColor
		
		stackView.addArrangedSubview(result)
		
		return result
	}
}

// MARK: - Signals handling

extension FilesSettingsView {
	
	fileprivate func setupTotalSnapshotSizeSignal() {
		Database.totalSnapshotsSize.bind(to: self) { me, value in
			gdebug("Total snapshot size changed to \(value)")
			UIView.animate(withDuration: 0.25) {
				me.deleteSnapshotsButton.isHidden = value == 0
				me.deleteSnapshotsButton.attributedTitle = me.deleteSnapshotsText()
			}
		}
	}
	
	fileprivate func setupTotalSignalsButtonTapSignal() {
		deleteSnapshotsButton.reactive.tap.bind(to: self) { me, _ in
			ginfo("Deleting all snapshots")
			Alert.deleteAllSnapshots { error in
				if let error = error {
					UIViewController.current.present(error: error)
				}
			}
		}
	}
}

// MARK: - Styling

extension FilesSettingsView {
	
	/**
	Prepares text for delete snapshot button.
	*/
	fileprivate func deleteSnapshotsText() -> NSAttributedString? {
		let size = Database.totalSnapshotsSize.value
		
		if size == 0 {
			return nil
		}
		
		let value = Formatter.size(fromBytes: size)

		let result = NSMutableAttributedString()
		result.append(value.value.set(style: FilesSettingsView.buttonValueStyle))
		result.append(value.unit.set(style: FilesSettingsView.buttonStyle))
		return result
	}

	private static let buttonStyle = Styles.style(appearance: [.light, .warning], size: .main)
	private static let buttonValueStyle = Styles.style(appearance: [.emphasized, .warning], size: .main)
}
