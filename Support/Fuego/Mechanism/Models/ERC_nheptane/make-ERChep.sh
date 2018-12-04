
CHEMINP=mech.dat
THERMINP=therm.dat
FINALFILE=ERC_nheptane.c

FMC=${PELE_PHYSICS_HOME}/Support/Fuego/Pythia/products/bin/fmc.py
HEADERDIR=${PELE_PHYSICS_HOME}/Support/Fuego/Mechanism/Models/header

CHEMLK=chem.asc
LOG=chem.log
CHEMC=chem.c

${FUEGO_PYTHON} ${FMC} -mechanism=${CHEMINP} -thermo=${THERMINP} -name=${CHEMC}
#cat ${CHEMC} \
#          ${HEADERDIR}/header.start\
#          ${HEADERDIR}/header.mec   ${CHEMINP}\
#          ${HEADERDIR}/header.therm ${THERMINP}\
#          ${HEADERDIR}/header.trans ${TRANINP}\
#          ${HEADERDIR}/header.end > ${FINALFILE}
cat ${CHEMC} > ${FINALFILE}
rm -f ${CHEMC} ${CHEMLK} ${LOG} 