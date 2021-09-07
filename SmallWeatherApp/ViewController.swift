//
//  ViewController.swift
//  SmallWeatherApp
//
//  Created by Monisha Ravi on 9/2/21.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var zipSearchTextField: UITextField!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var cityTemperatureLabel: UILabel!
    let apiKey = "K9ThwCmT3GORmKWcF8osHlQ9TaviWkXV"
    var zipCode: String = ""
    var locationKey: String = ""
    var cityName: String = ""
    var cityTemperature: Double = 0.0
    var cityTemperatureUnit: String = ""
    var cityTemperatureUnitType: Int32 = 0
    var cityTemperatureInFahrenheit: Double = 0.0
    
    //button f(x)
    @IBAction func searchCity(_ sender: UIButton) {
        zipCode = zipSearchTextField.text! // set zipcode to user input
        print(zipCode)
        callTemperatureAPI(locationKey: LocationAPI())
    }
    //parse for location key
   public func LocationAPI() -> String {
        print("REACHED LOCATION API")
        let url = URL(string: "http://dataservice.accuweather.com/locations/v1/postalcodes/search?apikey=\(apiKey)&q=\(zipCode)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session: URLSession = {
               let config = URLSessionConfiguration.default
               return URLSession(configuration: config)
           }()
            print("REACHED SESSION")
            let task = session.dataTask(with: request) {
                (data, response, error) in
                if let jsonData = data {
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("LOCATION JSON: \(jsonString)")
                        let locations = try! JSONDecoder().decode([Location].self, from: jsonData)
                        if let location = locations.first {
                            self.cityName = location.LocalizedName
                            self.locationKey = location.Key
                            print("LOCATION KEY \(self.locationKey)")
                            DispatchQueue.main.async {
                                self.cityNameLabel.text = self.cityName
                            }
                        }
                        
                    }
                    
                    
                    } else if let requestError = error {
                    print("Error fetching location: \(requestError)")
                    } else {
                    print("Unexpected error fetching location")
                    }
            }
        
        task.resume()
    print("LOCATION KEY: \(locationKey)")
    return locationKey
       }
        
   //  parse for temperature
    func callTemperatureAPI(locationKey: String) {
        print("REACHED TEMPERATURE API")
        print("REACHED LOCATION KEY:\(locationKey)")
        let url = URL(string: "http://dataservice.accuweather.com/forecasts/v1/hourly/1hour/\(locationKey)?apikey=K9ThwCmT3GORmKWcF8osHlQ9TaviWkXV&language=en-us&details=false&metric=true")!
        print("URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session: URLSession = {
               let config = URLSessionConfiguration.default
               return URLSession(configuration: config)
           }()

            let task = session.dataTask(with: request) {
                (data, response, error) in
                if let jsonData = data {
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("TEMPERATUREJSON: \(jsonString)")

                        let response = try? JSONDecoder().decode([Forecast].self, from: jsonData)

                        if let temperature = response?.first?.Temperature {
                            print("TEMP \(temperature.Value)")
                            self.cityTemperature = temperature.Value
                            self.cityTemperatureUnit = temperature.Unit
                            self.cityTemperatureInFahrenheit = self.cityTemperature * 1.8 + 32
                            self.cityTemperatureUnitType = temperature.UnitType
                            print("CITY TEMP \(self.cityTemperature)")
                        }
                    }

                    DispatchQueue.main.async {
                        self.cityTemperatureLabel.text = String(self.cityTemperatureInFahrenheit).appending(" °F")
                    }
                } else if let requestError = error {
                    print("Error fetching temperature: \(requestError)")
        } else {
                    print("Unexpected error fetching temperature")
                }
        }

        print("CITY TEMPERATURE: \(String(describing: cityTemperatureLabel.text))")
          task.resume()

       }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBlue
        // Do any additional setup after loading the view.
    }


}

