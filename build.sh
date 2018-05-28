#!bin/bash
echo "Accediendo a la version Secuencial..."
cd Secuencial
g++ dfs.cpp -o dfs -lm
echo "Codigo secuencial compilado exitosamente..."
echo "Accediendo a la version OMP"
cd ../OpenMP
g++ dfs.cpp -o dfs -lm -fopenmp
echo "Codigo omp compilado exitosamente..."

