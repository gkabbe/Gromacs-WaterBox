#!/bin/bash

# Create box with box lengths 6 x 6 x 6 nm^3
gmx solvate -box 6 6 6 -o water_neutral.gro

# Create topology file using the Amber force field
gmx pdb2gmx -f water_neutral.gro -o water_neutral_processed.gro -water spce -ff "amber03"

# Create a run file for the energy minimization
gmx grompp -f minim.mdp -c water_neutral_processed.gro -p topol.top -o energy_minimization.tpr

# Start the energy minimization
gmx mdrun -v -deffnm energy_minimization -o ener_min

# Create a run file for the equilibration
gmx grompp -v -f equilibration.mdp -c energy_minimization.gro -p topol.top -o nvt.tpr

# Start the equilibration
gmx mdrun -v -deffnm nvt
