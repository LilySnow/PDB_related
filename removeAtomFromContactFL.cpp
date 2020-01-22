// Li Xue
// Nov. 17th 2014
//
// reformat contact file
//
// Input format:
// LYS A   1331     CB     ASP B     38     OD1    4.93816
// LYS A   1331     CG     ASP B     38     CG     4.64661
// LYS A   1331     CG     ASP B     38     OD1    3.51515
// LYS A   1331     CD     ASP B     38     CG     4.49075
// LYS A   1331     CD     ASP B     38     OD1    3.50583
//
// Output format:
// ALA A 1405 LEU B 70 min_dist1
// ARG A 1369 ILE B 33 min_dist2
// ARG A 1469 GLN B 74 min_dist3
// ASN A 1406 ARG B 66 min_dist4

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <unordered_map>
#include <iomanip> // for setprecision

using namespace std;



unordered_map <string, double> read_contactFL_atomLevel(string CONTACTFL_atomLevel){
    // Note: For each residue pair, the minimum atom-atom distance is kept.

    ifstream contactFL  (CONTACTFL_atomLevel);
        if (!contactFL.is_open()){
            cout << "Cannot open CONTACTFL_ori" <<endl;
        }

//        unordered_map <string,string> line_residueLevel;
        unordered_map <string,double> min_dist_residueLevel;

        string line;
        string residue1, chnID1, atom1, residue2, chnID2, atom2, atomResNum2,atomResNum1;
        double dist;

        while(getline(contactFL,line)){
        stringstream iss(line);
        iss>> residue1;
        iss>>chnID1;
        iss>> atomResNum1;
        iss>> atom1;
        iss>>residue2;
        iss>> chnID2;
        iss>>atomResNum2;
        iss>> atom2;
        iss>> dist;

        string ID= residue1 + '\t' + chnID1 + '\t' +  atomResNum1 + '\t' + residue2 + '\t' + chnID2 + '\t' + atomResNum2;

        auto it = min_dist_residueLevel.find(ID);
        if (it != min_dist_residueLevel.end()){
            // this ID has been stored in min_dist_residueLevel before
            if (it->second > dist){
                it->second = dist; //keep the smaller dist
            }

        }
        else{
            // this ID is new
           min_dist_residueLevel[ID]= dist;
        }

    //    line_residueLevel[ID]=1;
    }
   contactFL.close();

   return min_dist_residueLevel;

}

int main (int argc, char *argv[]){
    if (argc< 2){
        cout << '\n'<<"USAGE: reformatContactFL contactFL_atomLevel "<<endl<<endl;
        exit(0);
    }
    string CONTACTFL_ori = string(argv[1]);
    unordered_map <string , double> contacts_residue_level;
    contacts_residue_level = read_contactFL_atomLevel(CONTACTFL_ori);
    for (auto it = contacts_residue_level.begin(); it != contacts_residue_level.end(); ++it){
        cout << it->first << "\t" << setprecision(4) << it->second << endl;
    }

    return 0;

}

