//
//  Created by Tomaz Kragelj on 9.06.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import Foundation

extension Date {
	
	/**
	Prepares array of standard date ranges together with their names.
	
	Standard ranges are "today", "this week", "previous week", "last month", "last year", "previous years", though some ranges are only returned depending current date. The date in each descriptor represents starting date in the range. In other words: when comparing if certain date belongs to certain group, use greater than or equal comparison (but less than date in the next range).
	
	Note: resulting array may be variable size depending on current date. For example: if right now is the last day of the week, the date corresponding to "This week" is not used because we already have it for "today". Other ranges are represented always though.
	
	Note: that some computations may take relatively long time.
	*/
	static var standardRanges: [Descriptor] {
		var result = [Descriptor]()
		let calendar = Calendar.current
		
		// Prepare the date representing today's midnight.
		let today = Date().removingTime
		var previousStartDate = today.addingTimeInterval(-1)
		
		// Today: end date is midnight tonight which we get by adding one day to "now" and reset time components to 0.
		let midnight = today.adding { $0.day = 1 }
		result.append(Descriptor(today, midnight, NSLocalizedString("Today")))
		
		// This week is used always, except if we're on first day of week.
		let thisWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: today)!
		if today > thisWeekInterval.start {
			result.append(Descriptor(thisWeekInterval.start, previousStartDate, NSLocalizedString("This Week")))
			previousStartDate = thisWeekInterval.start.addingTimeInterval(-1)
		}
		
		// Previous week is always used.
		let previousWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: thisWeekInterval.start.addingTimeInterval(-1))!
		result.append(Descriptor(previousWeekInterval.start, previousStartDate, NSLocalizedString("Previous Week")))
		previousStartDate = previousWeekInterval.start.addingTimeInterval(-1)

		// Last month is always counted 5 weeks from today.
		let lastMonthDate = today.adding { $0.weekOfMonth = -5 }
		result.append(Descriptor(lastMonthDate, previousStartDate, NSLocalizedString("Last Month")))
		previousStartDate = lastMonthDate.addingTimeInterval(-1)
		
		// Last year is always counted 12 months from today.
		let lastYearDate = today.adding { $0.year = -1 }
		result.append(Descriptor(lastYearDate, previousStartDate, NSLocalizedString("Last Year")))
		previousStartDate = lastYearDate.addingTimeInterval(-1)
		
		// Previous years begin just before last year and last "forever"
		result.append(Descriptor(previousStartDate, Date.distantPast, NSLocalizedString("Previous Years")))
		
		return result
	}
	
	/**
	Returns date by setting the components from the given handler as absolute values.
	*/
	func setting(handler: ((inout DateComponents) -> Void)) -> Date {
		let calendar = Calendar.current
		var components = calendar.dateComponents(in: TimeZone.current, from: self)
		handler(&components)
		return calendar.date(from: components)!
	}
	
	/**
	Returns relative date from now using the components from the given handler for offset.
	*/
	func adding(handler: ((inout DateComponents) -> Void)) -> Date {
		return adding(to: Date(), handler: handler)
	}
	
	/**
	Returns relative date from given date using the components from the given handler as offset.
	*/
	func adding(to date: Date, handler: ((inout DateComponents) -> Void)) -> Date {
		let calendar = Calendar.current
		var components = DateComponents()
		handler(&components)
		return calendar.date(byAdding: components, to: date)!
	}
	
	/**
	Returns new date by removing time.
	
	Note this is convenience shortcut for `setting { $0.hour = 0; $0.minute = 0; $0.second = 0; #0.nanosecond = 0 }`.
	*/
	var removingTime: Date {
		return setting { components in
			components.hour = 0
			components.minute = 0
			components.second = 0
			components.nanosecond = 0
		}
	}
	
	/**
	Date range descriptor.
	*/
	final class Descriptor: CustomStringConvertible {
		/// Localized name of the range.
		let name: String
		
		/// Range starting date.
		let startDate: Date
		
		/// Range ending date.
		let endDate: Date
		
		fileprivate init(_ start: Date, _ end: Date, _ name: String) {
			self.startDate = start
			self.endDate = end
			self.name = name
		}
		
		var description: String {
			return "'\(name)' in range of \(startDate) to \(endDate)"
		}
	}
}
