
double processArray(float* floats, int size){
    double sum = 0;
    for(int i = 0; i < size-1; i++){
        double temp = (double) floats[i];
        double temp2 = (double) floats[i+1];
        
        temp *= temp2

        sum += temp;
    }
}
