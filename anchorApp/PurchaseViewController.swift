//
//  PurchaseViewController.swift
//  anchorApp
//
//  Created by ÖMER BOZKURT on 28.02.2022.
//

import UIKit
import StoreKit
class PurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
  
    var timer : Timer?
    var counter : Int = 1
    
    @IBOutlet var useFreeButton: UIButton!
    
    enum Product : String, CaseIterable
    {
    case monthly = "com.merveunver.monthly"
    case yearly = "com.merveunver.yearly"
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let oProduct = response.products.first{
            print("Product is avaible")
            self.purchase(aproduct: oProduct)
        }else{
            print("Product is not avaible")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState{
            case .purchasing:
                print("Customer is in the process of purchase")
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchased")
                performSegue(withIdentifier: "toMain", sender: nil)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Failed")
            case .restored:
                print("restored")
            case .deferred:
                print("deferred")
            default:break
            }
        }
    }
    
    func purchase(aproduct: SKProduct){
        let payment = SKPayment(product: aproduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
    }
    
    
    @IBAction func useFree(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Counter), userInfo: nil, repeats: true)
        performSegue(withIdentifier: "toMain", sender: nil)
        
    }
    
    @objc func Counter(){
        counter = counter+1
        //259200 sn
        if counter > 6{
            print("Time is over.")
            timer?.invalidate()
            dismiss(animated: true, completion: nil)
            useFreeButton.isEnabled = false
            useFreeButton.isHidden = true
        }
        
    }
    @IBAction func buyMountly(_ sender: Any) {
        if SKPaymentQueue.canMakePayments(){
            let set : Set<String> = [Product.monthly.rawValue]
            let productRequest = SKProductsRequest(productIdentifiers: set)
            productRequest.delegate = self
            productRequest.start()
            
        }
        
    }
    
    @IBAction func buyYearly(_ sender: Any) {
        if SKPaymentQueue.canMakePayments(){
            let set : Set<String> = [Product.yearly.rawValue]
            let productRequest = SKProductsRequest(productIdentifiers: set)
            productRequest.delegate = self
            productRequest.start()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
  
}
