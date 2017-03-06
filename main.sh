#!/bin/bash

git clean -f

# Create box with box lengths 4 x 4 x 4 nm^3
gmx solvate -box 2 2 2 -o water_neutral.gro

# Create topology file using the Amber force field
gmx pdb2gmx -f water_neutral.gro -o water_neutral_processed.gro -water tip4p -ff "amber03"

# Create a run file for the energy minimization
gmx grompp -f minim.mdp -c water_neutral_processed.gro -p topol.top -o energy_minimization.tpr

# Start the energy minimization
gmx mdrun -v -deffnm energy_minimization -o ener_min

# Create a run file for the equilibration
gmx grompp -v -f equilibration.mdp -c energy_minimization.gro -p topol.top -o nvt.tpr

# Start the equilibration
gmx mdrun -v -deffnm nvt


# The following commands are optional, as the density is already close to the experimental value

# Create run file for equilibration with pressure coupling
# gmx grompp -v -f pressure_coupling.mdp -c nvt.gro -t nvt.cpt -p topol.top -o npt.tpr

# Optimize box size
# gmx mdrun -v -deffnm npt

# Create run file for production run
gmx grompp -v -f production_run.mdp -c nvt.gro -t nvt.cpt -p topol.top -o production.tpr


# Start production run
gmx mdrun -v -deffnm production


# Convert trajectory to pdb
gmx trjconv -f production.trr -s production.tpr -pbc nojump -o out.pdb
babel -i pdb out.pdb -o xyz out.xyz
