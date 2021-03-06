//
//  ForecastWeatherObj.swift
//  HW_9 (Caching with Realm)
//
//  Created by Elizaveta Rogozhina on 18.09.2021.
//

import Foundation
import RealmSwift

class UnDayForTableClass: Object {
    @objc dynamic var un_date = ""
}

class DayForTableClass: Object {
    @objc dynamic var date = ""
}
class DescriptForTableClass: Object {
    @objc dynamic var descript = ""
}
class TimeForTableClass: Object {
    @objc dynamic var time = ""
}
class TempForTableClass: Object {
    @objc dynamic var temp = ""
}

class ForecastWeather: Object{
    let descripts = List<DescriptForTableClass>(),
        un_dates = List<UnDayForTableClass>(),
        all_dates = List<DayForTableClass>(),
        times = List<TimeForTableClass>(),
        temps = List<TempForTableClass>()
}
