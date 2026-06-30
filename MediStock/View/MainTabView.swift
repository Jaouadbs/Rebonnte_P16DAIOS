
// la barre de navigation (Tab Bar)
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {

            //Liste des allées / rayons de stockage
            AisleListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Aisles")
                }

            //Catalogue complet des médicaments
            AllMedicinesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("All Medicines")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
