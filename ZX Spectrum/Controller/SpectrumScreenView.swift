//
//  Created by Tomaz Kragelj on 6.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class SpectrumScreenView: UIView {
	
	static func hookToFuse() {
		set_display_init_function { (width, height) -> Int32 in
			print("Initializing display for \(width) x \(height)")
			return 0
		}
		
		set_display_hotswap_gfx_mode_function { () -> Int32 in
			return 0
		}
		
		set_display_putpixel_function { (x, y, colour) in
			print("putpixel \(x),\(y)")
		}
		
		set_display_plot8_function { (x, y, data, ink, paper) in
			print("plot8 \(x),\(y) d\(data) i\(ink) p\(paper)")
		}
		
		set_display_plot16_function { (x, y, data, ink, paper) in
			print("plot16 \(x),\(y) d\(data) i\(ink) p\(paper)")
		}
		
		set_display_area_function { (x, y, width, height) in
			print("area \(x),\(y) \(width)x\(height)")
		}
		
		set_display_frame_end_function { 
			print("frame end")
		}
		
		set_display_end_function { 
			print("display end")
		}
	}
}
