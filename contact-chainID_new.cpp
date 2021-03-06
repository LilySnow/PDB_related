#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
//#include <cstdio>
#include <stdlib.h>
#include <cstring>
#include <string>
//#include <map>
//#include <set>
#include <vector>
#include <cmath>
using namespace std;

struct Coor3f {
  float x;
  float y;
  float z;
};

struct Atom{
    string atomResNum;
    string chnID;
    double x;
    double y;
    double z;
    string atomName;
    string resiName;
};

vector<Atom> atoms;

int main(int argc, char *argv[]) {

  if (argc < 3) {
    fprintf(stderr,"ERROR: Too few arguments\n");
    fprintf(stderr, "Usage: contact <pdb file> <cutoff>\n");
    return 1;
  }

  char *filename = argv[1];
  float cutoff = atof(argv[2]); // distance cutoff

  if (cutoff < 0 || cutoff > 100) {
    fprintf(stderr,"ERROR: Cutoff out of range\n");
    fprintf(stderr, "Usage: contact <pdb file> <cutoff>\n");
    return 1;
  }

  std::string line;
  std::ifstream inputFL(filename);
  while(std::getline(inputFL,line)){

      string label = line.substr(0,5);

      if (label.find("ATOM") != string::npos){
          // if this line starts with 'ATOM'
         string resiName = line.substr(17,3);
         string chnID = line.substr(21,1);
         string atomName = line.substr(12,4);
         string atomResNum = line.substr(22,4);

         istringstream is(line.substr(30,8));
         double x ;
         is >> x;

         istringstream is1(line.substr(38,8));
         double y;
         is1 >> y;

         istringstream is2(line.substr(46, 8) );
         double z;
         is2 >> z;

         Atom Atm;
         Atm.resiName = resiName;
         Atm.chnID = chnID;
         Atm.atomName = atomName;
         Atm.atomResNum = atomResNum;
         Atm.x=x;
         Atm.y=y;
         Atm.z=z;

         atoms.push_back(Atm); // add the current Atm to the vector of atoms

/*         cout << x << endl;
         cout << y << endl;
         cout << z << endl;
         cout << chnID << endl;
         */

      }
 }
  if (!atoms.size()) {fprintf(stderr, "ERROR: PDB file %s contains no residues\n", filename); return 1;}
  double cutoffsq = cutoff*cutoff;

  for (int i=0;i<atoms.size();i++){

      for(int j=i+1; j<atoms.size();j++){
        string chnID_i = atoms[i].chnID;
        string chnID_j = atoms[j].chnID;
        if (chnID_i == chnID_j) continue;
        double currdissq=(atoms[i].x - atoms[j].x)* (atoms[i].x - atoms[j].x) +(atoms[i].y - atoms[j].y)*(atoms[i].y - atoms[j].y) + (atoms[i].z - atoms[j].z)* (atoms[i].z - atoms[j].z);

        if (currdissq < cutoffsq){
            cout << atoms[i].resiName << "\t" << atoms[i].chnID << "\t" << atoms[i].atomResNum << "\t" << atoms[i].atomName ;
            cout <<  "\t" << atoms[j].resiName << "\t" << atoms[j].chnID << "\t"<< atoms[j].atomResNum << "\t"<<  atoms[j].atomName;
            cout << "\t" << sqrt(currdissq) << endl;

    }
  }
  }

}
