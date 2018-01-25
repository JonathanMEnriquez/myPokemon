//
//  ViewController.swift
//  myPokemon
//
//  Created by user on 1/24/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet var myTableView: UITableView!
    
    var pokeTypeArr = ["Fire", "Water", "Grass", "Rock", "Electric"]
    var colorArr: [UIColor] = [.red, .blue, .green, .gray, .orange]
    var pokemonArr = [Pokemon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //Core Data
    
    func saveContext() {
        
        print("in save context")
        if managedObjectContext.hasChanges {
            
            do {
                try managedObjectContext.save()
            } catch {
                print("failed to save", error)
            }
        }
    }
    
    func fetchAndReload(type: String?) {
        
        let request:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        if let myType = type {
            request.predicate = NSPredicate(format: "type CONTAINS %@", myType)
        }
        
        do {
            let result = try managedObjectContext.fetch(request)
            pokemonArr = result
        } catch {
            print("failed in fetch", error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addPokemonSegue" {
            let destination = segue.destination as! AddPokemonViewController
            destination.delegate = self
        }
        if segue.identifier == "showPokemonSegue" {
            let destination = segue.destination as! ShowPokemonTableViewController
            let cell = sender as! IndexPath
            let type = pokeTypeArr[cell.row]
            destination.type = type
            fetchAndReload(type: type)
            print(pokemonArr.count)
            destination.pokemon = pokemonArr
            destination.tableView.backgroundColor = colorArr[cell.row]
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showPokemonSegue", sender: indexPath)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pokeTypeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        let type = pokeTypeArr[indexPath.row]
        cell.textLabel?.text = "My " + type + " Type"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = colorArr[indexPath.row]
        tableView.rowHeight = 105
        return cell
    }
}

extension HomeViewController: AddPokemonViewControllerDelegate {
    
    func addPokemonUpdateType(name: String, type: String, weight: Double, number: Int) {
        
         // Add type if it doesn't exist
        if pokeTypeArr.contains(type) == false {
            pokeTypeArr.append(type)
            //add color
            colorArr.append(.white)
            myTableView.reloadData()
        }
        let newPoke:Pokemon = Pokemon(context: managedObjectContext)
        newPoke.name = name
        newPoke.type = type
        newPoke.weight = weight
        newPoke.number = Int64(number)
        saveContext()
        print("saved successfully")
        navigationController?.popViewController(animated: true)
    }
}
