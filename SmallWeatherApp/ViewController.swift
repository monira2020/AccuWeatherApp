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
    
    /*
     * The locationAPI function (1) uses global variables apiKey and zipCode to perform a get request
     * to the AccuWeather postal codes location API (2) then encodes the response data into a json string
     * (3) then decodes the jsonString using a Location struct (Location.swift) into cityName and
     * locationKey global variables. It then (4) sets the UILabel cityNameLabel to the cityName global variable
     * and (5) calls the temperatureAPI.
     */
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
        
    /*
     * The temperatureAPI function (1) uses global variables apiKey and locationKey to perform a get request
     * to the AccuWeather next hourly temperature API (2) then encodes the response data into a json string
     * (3) then decodes the jsonString using a Temperature struct (Temperature.swift) into a Celsius cityTemperature
     * global variable. It then (4) rounds and converts Celsius response to Fahrenheit and (5) sets the UILabel
     * cityTemperatureLabel to the cityTemperature global variable and (6) appends string fahrenheit unit.
     */
    func temperatureAPI() {
        let url = URL(string: "http://dataservice.accuweather.com/forecasts/v1/hourly/1hour/\(locationKey)?apikey=\(apiKey)&language=en-us&details=false&metric=true")!
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
                            self.cityTemperatureInFahrenheit = round(self.cityTemperature * 1.8 + 32)
    
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

    /*
     * The viewDidLoad function loads a system color blue background and sets placeholder property of
     * UITextField zipSearchTextField.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBlue
        zipSearchTextField.attributedPlaceholder = NSAttributedString(string: "zipCode",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        // Do any additional setup after loading the view.
    }


}

