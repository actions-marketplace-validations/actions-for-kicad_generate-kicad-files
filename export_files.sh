#!/bin/bash

# Check if the input file name is supplied.
if [ -z "$1" ]; then
  echo "::error::Please supply source file"
  exit 1
fi

# Check if the export type is supplied.
if [ -z "$2" ]; then
  echo "::error::Please supply type"
  exit 1
fi

# Check if kicad is installed
kicad_version="$(kicad-cli --version)"
if [ -z "$kicad_version" ]; then
  echo "::error::Please make sure kicad is installed"
  exit 1
fi

# Get the fil_name without file type
file_name="$(echo $1 | rev | cut -d '/' -f 1 | rev | cut -d '.' -f 1)"

# Export the schematic
if [ "$2" = "schematic_pdf" ]; then
  kicad-cli sch export pdf "$1"
elif [ "$2" = "schematic_svg" ]; then
  kicad-cli sch export svg "$1"
elif [ "$2" = "schematic_bom" ]; then
  kicad-cli sch export python-bom "$1"
elif [ "$2" = "schematic_netlist" ]; then
  kicad-cli sch export netlist "$1"
elif [ "$2" = "pcb_step" ]; then
  kicad-cli pcb export step --subst-models "$1"
elif [ "$2" = "pcb_pos" ]; then
  kicad-cli pcb export pos "$1"
elif [ "$2" = "pcb_gerbers" ]; then
  kicad-cli pcb export gerbers -l "$3" "$1"
  zip "${file_name}-gerbers.zip" *.g*
elif [ "$2" = "pcb_drill" ]; then
  kicad-cli pcb export drill "$1"
elif [ "$2" = "pcb_gerbers_drill" ]; then
  kicad-cli pcb export gerbers -l "$3" "$1"
  kicad-cli pcb export drill "$1"
  zip "${file_name}-gerbers.zip" *.g* *.drl
else
  echo "::error::Type is not correct"
  exit 1
fi

# Give error if the export is failed
if [ "$?" != "0" ]; then
  echo "::error::Export failed."
  exit 1
fi