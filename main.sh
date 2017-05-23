#!/bin/bash

git clean -f

# Create box with box lengths 2x2x2 nm^3
gmx solvate -scale 0.5 -cs -box 1.8626 1.8626 1.8626 -o water_neutral.gro

# gmx editconf -f water_neutral.gro -bt cubic -box 1.862017 -o water_neutral.gro

# Create topology file using the Amber force field
gmx pdb2gmx -f water_neutral.gro -o water_neutral_processed.gro -water tip4p -ff "amber03"

# Create a run file for the energy minimization
gmx grompp -f minim.mdp -c water_neutral_processed.gro -p topol.top -o input_energy_minimization.tpr

# Start the energy minimization
gmx mdrun -v -s input_energy_minimization.tpr -deffnm energy_minimization

# Create a run file for the equilibration
gmx grompp -v -f equilibration.mdp -c energy_minimization.gro -p topol.top -o input_nvt.tpr

# Start the equilibration
gmx mdrun -v -s input_nvt.tpr -deffnm nvt


# Create run file for equilibration with pressure coupling
#gmx grompp -v -f pressure_coupling.mdp -c nvt.gro -t nvt.cpt -p topol.top -o input_npt.tpr

# Optimize box size
#gmx mdrun -v -s input_npt.tpr -deffnm npt

 Create run file for production run
gmx grompp -v -f production_run.mdp -c nvt.gro -t nvt.cpt -p topol.top -o input_production.tpr


# Start production run
gmx mdrun -v -s input_production.tpr -deffnm production


# Convert trajectory to pdb
gmx trjconv -f production.trr -s production.tpr -pbc nojump -o out.pdb
babel -i pdb out.pdb -o xyz out.xyz
