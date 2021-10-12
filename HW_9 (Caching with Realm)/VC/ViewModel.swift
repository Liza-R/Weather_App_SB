//
//  ViewModel.swift
//  HW_9 (Caching with Realm)
//
//  Created by Elizaveta Rogozhina on 13.08.2021.
//

import Foundation
import UIKit
import Alamofire

class ViewModel{
    private var today_Alam: [CurrentWeatherStruct.Current_Info] = [],
                five_days_Alam: [ForecastWeatherStruct.Forecast_Info] = []

    func uploadCurrentInfo(){
        CorrentLoader().loadCurrentInfo { today in
            self.today_Alam = today
            DispatchQueue.main.async {
                for i in today{
                     var icon_today_Alam: String? = "",
                         descript: String = ""
                     
                     for j in i.weather{
                        icon_today_Alam = j?.icon
                        descript = j?.description ?? "Not Found"
                     }
                    
                    let url_icon_Al = URLs().url_icon_upload.replacingOccurrences(of: "PICTURENAME", with: "\(icon_today_Alam!)")

                    AF.request(URL(string: url_icon_Al)!, method: .get).response{ response in
                        switch response.result {
                            case .success(let responseData):
                                let ic = UIImage(data: responseData!, scale:1) ?? .checkmark,
                                date = NSDate(timeIntervalSince1970: TimeInterval(i.dt)),
                                        dayTimePeriodFormatter = DateFormatter()
                                dayTimePeriodFormatter.dateFormat = "YYYY-MM-dd"
                                let dateString = dayTimePeriodFormatter.string(from: date as Date),
                                    todayInfo = "\(String(describing: Int(i.main!.temp - 273.15)))°C \(i.name)",
                                    min_temp = "Min: \(String(describing: Int(i.main!.temp_min - 273.15)))°C",
                                    max_temp = "Max: \(String(describing: Int(i.main!.temp_max - 273.15)))°C",
                                    feelsL_temp = "Feels like: \(String(describing: Int(i.main!.feels_like - 273.15)))°C",
                                    dataIcon = NSData(data: ic.pngData()!)
                                RealmWeather().savingCurrentInfo(descr: descript, icon: dataIcon, cityName: todayInfo, tempFL: feelsL_temp, tempTMax: max_temp, tempTMin: min_temp, dt: dateString)

                            case .failure(let error):
                                print("error--->",error)
                        }
                    }
                }
            }
        }
    }
    
    func uploadForecastInfo(){
        var temp_: [String] = [],
            descript: [String] = [],
            iconLinkAlam: [String] = [],
            iconsAlam: [NSData] = [],
            data: [String] = [],
            time: [String] = [],
            cod: String = ""
  
        let date = Date(),
        formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        let result_Al = formatter.string(from: date)

        ForecastDaysLoader().loadForecastInfo { five_days in
            self.five_days_Alam = five_days
            DispatchQueue.main.async {
                for i in five_days{
                    cod = i.cod
                    for j in i.list{
                        let denechek = j?.dt_txt.components(separatedBy: " ")
                        if denechek![0] != result_Al{
                            temp_.append("\(String(describing: Int((j!.main!.temp) - 273.15)))°C ")
                            data.append(denechek?[0] ?? "Not Found")
                            time.append(denechek?[1] ?? "Not Found")
                            for (_, w) in (j?.weather.enumerated())!{
                                descript.append("\(w!.description)")
                                iconLinkAlam.append("\(w!.icon)")
                            }
                        }
                    }
                }
                for (_, j) in iconLinkAlam.enumerated(){
                    let url_icon = URLs().url_icon_upload.replacingOccurrences(of: "PICTURENAME", with: "\(j)")
                    AF.request(URL(string: url_icon)!, method: .get).response{ response in
                        switch response.result {
                            case .success(let responseData):
                                let ic = UIImage(data: responseData!, scale: 1) ?? .checkmark
                                iconsAlam.append(NSData(data: ic.pngData()!))
                                var moving = false
                                if iconsAlam.count == temp_.count{
                                    moving = true
                                }
                                if moving == true{
                                    var uniqDays = Array(Set(data))
                                    uniqDays = uniqDays.sorted()
                                    RealmWeather().savingForecastInfo(uniqDates: uniqDays, allDates: data, cod: cod, descripts: descript, icons: iconsAlam, temps: temp_, times: time)
                                }
                            case .failure(let error):
                                print("error--->",error)
                        }
                    }
                }
            }
        }
    }
}
