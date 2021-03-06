//
//  MemoryManag_Model.swift
//  BookMarkManagement_IOS
//
//  Created by Karthik on 15/02/22.
//

import Foundation
import SwiftUI


struct FolderValue : Decodable  {
    //    var createdAt, createdBy, modifiedAt, modifiedBy: String
    var ID, folder_name, email, maincategory: String
    var lastupdate: String
    var imageurl: String
    var favourites: Bool
    var visitedtimes, filecount: Int
    var lastvisited: String
    //    var isActiveEntity, hasActiveEntity, hasDraftEntity: Bool
}

struct CategoryVH : Decodable{
    var maincategory : String
}

struct FolderCategories : Decodable {
    var value: [CategoryVH]
}

struct FolderData : Decodable {
    var value: [FolderValue]
}

struct FolderDataFinal : Decodable {
    var category : String
    var Items : [FolderValue]
}

struct NewFolderModel: Codable{
 var   folder_name,email,maincategory, imageurl: String
    var favourites: Bool
}

class FolderdataAccessories : ObservableObject{
    @Published var categories :[String] = []
    @Published var results =  [FolderValue]()
    var FullData = [FolderValue]()
    @Published var showMenu = false
    @Published var FolderData = [FolderDataFinal]()
    var FolderDataAll = [FolderDataFinal]()
    @Published var FolderSearchString : String = ""
    @Published var SelectedCategory : String = ""
    @Published var EditPressed = false
    @Published var DeletePressed = false
    @Published var DeletionID = ""
    
    @Published var FolderCat  = [CategoryVH]()
    
    @Published var NewFolder = FolderValue(ID: "", folder_name: "", email: "karthi.hifi@gmail.com", maincategory: "", lastupdate: "", imageurl: "", favourites: false, visitedtimes: 0, filecount: 0, lastvisited: "")
    @Published var isNewFolder : Bool = false
    @Published var isEditFolder : Bool = false
    
     var FolderData1: [FolderDataFinal] { // 1
        if self.FolderSearchString.isEmpty {
            self.FolderData = self.FolderDataAll
            return self.FolderDataAll
            } else {
                let filtered = self.FolderDataAll.filter { item in
                    return  item.category == self.FolderSearchString
                }
                self.FolderData = filtered
                print("reaced",self.FolderSearchString)
                return filtered
            }
    }
    
    func EditFolder(FolderDetails : FolderValue){
        let dummyData = self.FolderDataAll
//        var catfound : Bool = false
        let item = FolderDataFinal(category: FolderDetails.maincategory, Items: [FolderDetails])
        for (index, Folder) in  dummyData.enumerated(){
            var folderIndex = Folder.Items.firstIndex(where: { $0.ID == FolderDetails.ID})!
            self.FolderDataAll[ index ].Items[ folderIndex ] = FolderDetails
        }
//        if catfound == false {
//            self.FolderDataAll.append(item)
//        }
    }
    
    func AddNewFolder(FolderDetails : FolderValue){
        let dummyData = self.FolderDataAll
        var catfound : Bool = false
        let item = FolderDataFinal(category: FolderDetails.maincategory, Items: [FolderDetails])
        for (index, item) in  dummyData.enumerated(){
            if item.category == FolderDetails.maincategory {
                self.FolderDataAll[ index ].Items.append(FolderDetails)
                catfound.toggle()
            }
        }
        if catfound == false {
            self.FolderDataAll.append(item)
        }
        print("Sending Request")
        SendnewFolderReq()
    }
    func GetSearchedItemsbyName(Folder: String)->[FolderDataFinal]{
        var item = FolderDataFinal(category: "", Items: [])
        var FolderData : [FolderDataFinal] = []
        var Categories : [String] = []
        let filtered = self.FullData.filter { item in
            return  item.folder_name.localizedCaseInsensitiveContains(Folder)
        }
        
        for item in filtered {
            Categories.append(item.maincategory)
        }
        
        let newCat = Array(Set(Categories))
        print(newCat,filtered,"sss",self.FullData.count,Folder)
        for cat in newCat {
            item.category = cat
            item.Items = filtered.filter { item in
                return  item.maincategory == cat
            }
            FolderData.append(item)
        }
        return FolderData
    }
    
    func DeleteFolder(Index : Int) ->[FolderDataFinal]{
        print(Index,"inside")
        print(self.FullData.count,self.FolderData.count,"Count")
        self.FullData.remove(at: Index)
//        self.GetFolderDetails()
        self.FolderData = []
        self.FolderDataAll = []
        self.GetFolderDetails()
        return self.FolderData
    }
    
    func GetFolderDetails(){
        var item = FolderDataFinal(category: "", Items: [])
        for category in categories {
            item.category = category
            item.Items = self.FullData.filter { item in
                return  item.maincategory == category
            }
            if(category == "All"){
                continue
            }
            if item.Items.count == 0 {
                let ind = self.categories.firstIndex(where: { $0 ==  category } )!
                self.categories.remove(at: ind)
                continue
            }
            self.FolderData.append(item)
            self.FolderDataAll.append(item)
        }
        //        print(FolderData,"FolderData")
    }
    
    func GetUniqueFolderCategories( FolderData : [FolderValue]) -> [String]{
        var Categories = [String]()
        for item in FolderData{
            Categories.append(item.maincategory)
        }
        //        Categories.insert("All", at: 0)
        var UniqueCat = Array(Set(Categories))
        UniqueCat.insert("All", at: 0)
        return UniqueCat
    }
    
    func GetFilteredFolders(Category: String)-> [FolderDataFinal]{
        if Category == "All"{
            return self.FolderDataAll
        }
        let filtered = self.FolderDataAll.filter { item in
            return  item.category == Category
        }
        return filtered
    }
    
    func DeleteFolder(at offsets: IndexSet, from category: Category){
        print(offsets,"offsets", category)
//        FolderData.remove(atOffsets: offsets)
//        print(FolderData)
    }
    
    func SendnewFolderReq(){
        guard let url = URL(string: "https://b8076800trial-dev-contentmanagement-srv.cfapps.us10.hana.ondemand.com/content-manag/Folder") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let newFolder = NewFolderModel(folder_name: "test", email: "test@gmail.com", maincategory: "test", imageurl: "", favourites: true)
        let jsonData = try? JSONEncoder().encode(newFolder)
        request.httpBody = jsonData
        print(request,"reqest")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                     print("Error took place \(error)")
                     return
                 }
            print(data,"Data asked")
//            if let response = response as? HTTPURLResponse {
//              print(response.location) // 200, 404, etc...
//            }
        }.resume()
    }
    func getCategories(){
        guard let url = URL(string: "https://b8076800trial-dev-contentmanagement-srv.cfapps.us10.hana.ondemand.com/content-manag/VH_categories") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
//                                print(response,"response",data,"Data asked")
                if let decodedResponse = try? JSONDecoder().decode(FolderCategories.self, from: data) {
                    DispatchQueue.main.async {
                        self.FolderCat = decodedResponse.value
//                        print("categories",self.FolderCat)
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    }
    //    func loadData() {
    //        guard let url = URL(string: "https://5aa7bb4ftrial-dev-contentmanagement-srv.cfapps.eu10.hana.ondemand.com/content-manag/Folder")
    //        else {
    //            print("Invalid URL")
    //            return
    //        }
    //
    //        let request = URLRequest(url: url)
    //
    //        URLSession.shared.dataTask(with: request) {data, response, error in
    //            if let data = data {
    //                //                print(data)
    //                if let decodedResponse = try? JSONDecoder().decode(FolderData.self, from: data) {
    //                    DispatchQueue.main.async {
    //                        self.results = decodedResponse.value
    //                        self.categories = self.GetUniqueFolderCategories(FolderData: self.results)
    ////                        print(self.FolderdataAccess.categories)
    //                    }
    //                    return
    //                }
    //            }
    //            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    //        }.resume()
    //    }
//}

class Theme {
    static func navigationBarColors(background : UIColor?,
                                    titleColor : UIColor? = nil, tintColor : UIColor? = nil ){
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = background ?? .clear
        
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .black]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .black]
        
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        
        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
    }
}






