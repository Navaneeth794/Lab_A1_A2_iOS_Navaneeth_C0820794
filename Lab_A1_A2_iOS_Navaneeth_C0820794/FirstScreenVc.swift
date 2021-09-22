//
//  FirstScreenVc.swift
//  Lab_A1_A2_iOS_Navaneeth_C0820794
//
//  Created by Mac on 2021-09-21.
//
import UIKit
import CoreData

class FirstScreenVc: UIViewController {
    var arrProducts = [Products]()
    var arrProviders = [Providers]()
    
    @IBOutlet weak var kindSwitch: UISwitch!
    let context =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchProducts()
    }
    @IBAction func addButtonClicked(_ sender: Any) {
        if !kindSwitch.isOn {
            performSegue(withIdentifier: "addProducts", sender: self)
        }
        else{
            let ac = UIAlertController(title: "Enter New provider", message: nil, preferredStyle: .alert)
                ac.addTextField()

                let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
                    let answer = ac.textFields![0]
                    let req : NSFetchRequest<Providers> = Providers.fetchRequest()
                    req.predicate = NSPredicate(format: "provider_name = '\(answer.text!)'")
                    let storeProvider = try! self.context.fetch(req)
                    if storeProvider.count == 0{
                        let provider = Providers(context: self.context)
                        provider.provider_name = answer.text
                    }
                    try! self.context.save()
                    self.fetchProviders()
                }
            let cancel  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                ac.addAction(submitAction)
            ac.addAction(cancel)

                present(ac, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  sender is String{
            if !kindSwitch.isOn{
                let vc = segue.destination as! ProductScreenVc
                vc.selectedProduct = arrProducts[tableView.indexPathForSelectedRow!.row]
            }
            else{
                let vc = segue.destination as! ProviderVc
                vc.provider = arrProviders[tableView.indexPathForSelectedRow!.row]
            }
        }
    }
    
    @IBAction func kindSwitchChnaged(_ sender: UISwitch) {
        if !sender.isOn{
            fetchProducts()
        }
        else{
            fetchProviders()
        }
    }
    func fetchProducts(){
        arrProducts.removeAll()
        do {
            arrProducts = try context.fetch(Products.fetchRequest())
        } catch  {
            
        }
        labtask2()
        tableView.reloadData()
    }
    func fetchProviders(){
        arrProviders.removeAll()
        do {
            arrProviders = try context.fetch(Providers.fetchRequest())
        } catch  {
            
        }
        tableView.reloadData()
    }
    func labtask2(){
        
        if arrProducts.isEmpty{
            let provider1 = Providers(context: context)
            let provider2 = Providers(context: context)
            for i in 1...10{
                if i < 6 {
                    let product  = Products(context: context)
                    product.product_desc = "Car \(i)"
                    product.product_id = "00\(i)"
                        provider2.provider_name = "BMW"
                        product.product_name = "Car \(i)"
                        product.provider = provider2
                }
                else{
                    
                let product  = Products(context: context)
                product.product_desc = "Bike \(i)"
                product.product_id = "00\(i)"
                    provider2.provider_name = "Yamaha"
                    product.product_name = "CBZ \(i)"
                    product.provider = provider1
                }
                
            }
            try! context.save()
            fetchProducts()
        }
        
    }
   
}
extension FirstScreenVc : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "product_name contains[c] '\(searchText)' || product_desc contains[c] '\(searchText)'")
            let fetchRequest : NSFetchRequest<Products> = Products.fetchRequest()
            fetchRequest.predicate = predicate
            do {
                arrProducts = try context.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error)")
            }
        }
        else{
            fetchProducts()
            
        }
        tableView.reloadData()
    }
    
}
extension FirstScreenVc : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !kindSwitch.isOn{
            return arrProducts.count
        }
        else{
            return arrProviders.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if !kindSwitch.isOn{
            cell.textLabel?.text =
                arrProducts[indexPath.row].product_name
            cell.detailTextLabel?.text = arrProducts[indexPath.row].provider?.provider_name
        }
        else{
            cell.textLabel?.text =
                arrProviders[indexPath.row].provider_name
            let req : NSFetchRequest<Products> = Products.fetchRequest()
            let productz = try! context.fetch(req)
            var count = 0
            for pro in productz{
                if pro.provider?.provider_name == arrProviders[indexPath.row].provider_name{
                    count = count + 1
                }
            }
            cell.detailTextLabel?.text = count.description
        }
        
        return cell
    }
    
    
}
extension FirstScreenVc : UITableViewDelegate{
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !kindSwitch.isOn{
            performSegue(withIdentifier: "goToProducts", sender: "FirstScreen")
        }
        else{
            performSegue(withIdentifier: "goToProviders", sender: "FirstScreen")
        }
    }
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if !kindSwitch.isOn{
                let objc = arrProducts[indexPath.row]
                context.delete(objc)
                try! context.save()
                fetchProducts()            }
            else{
                for prod in arrProducts{
                    if prod.provider?.provider_name == arrProviders[indexPath.row].provider_name{
                        context.delete(prod)
                    }
                }
                context.delete(arrProviders[indexPath.row])
                try! context.save()
                fetchProviders()
            }
            
            
            
        }
    }
}

