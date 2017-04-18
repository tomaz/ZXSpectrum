//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond

extension FilesViewController {
	
	/**
	Manages sizing for collection view
	*/
	final class Sizer: NSObject, UICollectionViewDelegateFlowLayout {
		
		/**
		Binds to given collection view.
		*/
		func bind(to collectionView: UICollectionView) {
			collectionView.reactive.delegate.forwardTo = self
		}
		
		func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
			let layout = collectionViewLayout as! UICollectionViewFlowLayout
			let width = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing
			return CGSize(width: width / 2.0, height: layout.itemSize.height)
		}
	}

	/**
	Bond for managing files collection view.
	*/
	final class Bond: CollectionViewBond {
		
		func cellForRow(at indexPath: IndexPath, collectionView: UICollectionView, dataSource: ObservableArray<FileObject>) -> UICollectionViewCell {
			let object = dataSource[indexPath.item]
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			let result = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as! FileCollectionViewCell
			result.configure(object: object)
			
			return result
		}
	}
}
