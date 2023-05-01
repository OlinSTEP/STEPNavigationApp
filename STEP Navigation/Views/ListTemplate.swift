//
//  ListTemplate.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/25/23.
//

//import SwiftUI
//
//protocol TemplateObject: Identifiable {
//    func getDisplayName()->String
//    func lessThan(_ other: any TemplateObject)->Bool
//}
//
//struct ListTemplate: View {
//    let list: [TemplateObject]
//    let destinationName: any View
//
//    var body: some View {
//        Text("Hello, World!")
//        ForEach(list.sorted(by: { $0.lessThan($1) })) {
//            item in
//            NavigationLink (
//                destination: destinationName,
//                label: {
//                    Text(item.getDisplayName())
//                        .font(.largeTitle)
//                        .bold()
//                        .padding(30)
//                        .frame(maxWidth: .infinity)
//                        .frame(minHeight: 140)
//                        .foregroundColor(AppColor.black)
//                })
//            .background(AppColor.accent)
//            .cornerRadius(20)
//            .padding(.horizontal)
//        }
//        .padding(.top, 20)
//
//    }
//}
//
//struct ListTemplate_Previews: PreviewProvider {
//    static var previews: some View {
//        ListTemplate()
//    }
//}
