// calculate the contacts within the same chain
#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <tuple>
#include <unordered_map>
#include <cmath>
using namespace std;



const int max_atomNum = 100000;
struct Atom{
    float x,y,z;
    string chnID, resiNum, resiName, atomName, atomNum;
};

tuple<Atom *, int, unordered_map <string,int>> readPDBFL (string PDBFL, string chnID_target){

   //    string PDBFL = "3ltj.pdb";
  Atom * atoms = new Atom[max_atomNum];
  Atom atom ;
  string line;
  string resiNum;
  string resiName;
  string chnID;
  string atomName;
  string atomNum;
  unordered_map <string,int> chnIDs; //a hash table
  string x_tmp, y_tmp, z_tmp;
  double x,y,z;
  int atom_num =0;
  ifstream pdbFL (PDBFL);
  if(! pdbFL.is_open()){

      cout << "Cannot open "<< PDBFL <<'\n';
      exit(0);
  }

    while(getline (pdbFL, line)){
        //cout <<line<<'\n';
        string record_name=line.substr(0,6);

        //if ( record_name.find("ATOM") == string::npos  && record_name.find("HETATM")){
        if ( record_name.find("ATOM") == string::npos  ){
            continue;
        }

        resiName= line.substr(17,3);
        resiNum = line.substr(22, 5); //residue number including the insertion code
        atomName = line.substr(12,4);
        atomNum = line.substr(6,5);

        chnID=line.substr(21,1);

        if (chnID.compare(chnID_target ) !=0 ){
            // this chain is not the target chain
            continue;
        }

        chnIDs[chnID]=1;
    //   cout <<chnID<<'\n';

        x_tmp=line.substr(30,8);
        x=atof(x_tmp.c_str()); // c_str() converts a C++ string to C-style string

        y_tmp=line.substr(38,8);
        y=atof(y_tmp.c_str()); // c_str() converts a C++ string to C-style characters

        z_tmp=line.substr(46,8);
        z=atof(z_tmp.c_str()); // c_str() converts a C++ string to C-style characters

        //cout << x << '\n';
        //cout << y << '\n';
        //cout << z << '\n';

        atom.x=x;
        atom.y=y;
        atom.z=z;
        atom.chnID = chnID;
        atom.resiName=resiName;
        atom.resiNum=resiNum;
        atom.atomName = atomName;
        atom.atomNum = atomNum;

        atoms[atom_num]= atom;
        atom_num++;
        if (atom_num > max_atomNum){

            perror("atom num in this pdb file exceeds the maximum number allowed. Need to change the cpp file.");
            exit(1);
        }

}
pdbFL.close();

   return make_tuple(atoms,atom_num, chnIDs);
}


int main ( int argc, char *argv [] ) {

    if (argc <4){
        cout << '\n'<< "USAGE: contact_sameChn pdb_file chainID distance_threshold" << "\n\n";
        exit(0);


    }

    string PDBFL =string(argv[1]); //"3ltj.pdb";
   string chnID = string(argv[2]); // 'A'
   double dist_thr = atof(argv[3]);//5;

    Atom * atoms ;
    int atom_num;
    unordered_map <string,int> chnIDs;
    std::tie(atoms,atom_num, chnIDs)= readPDBFL(PDBFL, chnID);
    for (int i=0; i<atom_num; i++){

        Atom a = *(atoms+i);

        for (int j =i+1; j<atom_num;j++){
            Atom b = *(atoms+j);

            if (a.chnID.compare(b.chnID) !=0){
               // atoms a and b belong to different chains
                continue;
            }

        double dist = sqrt((a.x-b.x) * (a.x-b.x) + (a.y-b.y) * (a.y-b.y)+ (a.z-b.z)*(a.z-b.z) );

        if (dist < dist_thr){
            cout<< a.resiName <<  "\t" << a.chnID << "\t" << a.resiNum << "\t" << a.atomName << "\t" << a.atomNum << "\t"
            << b.resiName <<  "\t" << b.chnID << "\t" << b.resiNum << "\t" << b.atomName << "\t" << a.atomNum
                << "\t" << dist <<'\n';
        }



   }
    }
//    cout << "There are totally " << atom_num << " atoms in the input PDB file.\n";

    return 0;
}
