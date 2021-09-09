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
    
    /*
     * The dismissKeyboard function resigns first responder (dismisses keyboard) when user
     * taps outside the zipcode text field (search text field).
     */
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        zipSearchTextField.resignFirstResponder()
    }
    
    /*
     * The search city function (1) resigns first responder (dismisses keyboard) when user
     * taps search and then (2) sets the global zipCode variable to the user input text
     * and last (3) calls locationAPI.
     */
    @IBAction func searchCity(_ sender: UIButton) {
        zipSearchTextField.resignFirstResponder()
        zipCode = zipSearchTextField.text! // set zipcode to user input
        locationAPI()
    }
    
    //parse for location key
   public func locationAPI(){
        let url = URL(string: "http://dataservice.accuweather.com/locations/v1/postalcodes/search?apikey=\(apiKey)&q=\(zipCode)")!
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
                        self.temperatureAPI()
                    }
                    
                    
                    } else if let requestError = error {
                    print("Error fetching location: \(requestError)")
                    } else {
                    print("Unexpected error fetching location")
                    }
            }
        
        task.resume()
       }
        
   //  parse for temperature
    func temperatureAPI() {
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
                            self.cityTemperature = temperature.Value
                            self.cityTemperatureUnit = temperature.Unit
                            self.cityTemperatureInFahrenheit = round(self.cityTemperature * 1.8 + 32)
                            self.cityTemperatureUnitType = temperature.UnitType
    
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

          task.resume()

       }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBlue
        zipSearchTextField.attributedPlaceholder = NSAttributedString(string: "zipCode",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        // Do any additional setup after loading the view.
    }


}

