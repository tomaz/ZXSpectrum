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
}
