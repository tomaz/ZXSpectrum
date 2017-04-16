//
//  Created by Tomaz Kragelj on 17.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit
import Bond

extension FilesViewController {

	/**
	Bond for managing files collection view.
	*/
	final class Bond: CollectionViewBond {
		
		func cellForRow(at indexPath: IndexPath, collectionView: UICollectionView, dataSource: ObservableArray<FileObject>) -> UICollectionViewCell {
			let object = dataSource[indexPath.item]
			
			gdebug("Dequeuing cell at \(indexPath) for \(object)")
			let result = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath)
			
			return result
		}
	}
}
