
del /q sim
mkdir sim
copy *.hex sim
cd sim

C:\iverilog\bin\iverilog -g2005 -D ICARUS -I ../ -I ../../source -I ../../testbench -s testbench ../../source/*.v ../../testbench/*.v   >> log.txt 2>&1
C:\iverilog\bin\vvp -n -la.lst a.out >> log.txt 2>&1

cd ..


