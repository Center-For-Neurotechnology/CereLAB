Welcome to CereLAB v0.4!

This project uses copyrighted headers and libraries from Blackrock and borrows
heavily from this project to make the C++ wrappers: 
http://www.mathworks.com/matlabcentral/fileexchange/38964-example-matlab-class-wrapper-for-a-c++-class
which is covered under this license:
http://www.mathworks.com/matlabcentral/fileexchange/view_license?file_info_id=38964

Otherwise everything is covered under the MIT license :).

If you are running 64-bit MATLAB, you should be able to download the code and 
get started right away.  If you are running 32-bit MATLAB, you will need to 
compile the project first.  You can do this by typing:

mex('BStimulator_mex.cpp','BStimAPIx86.lib')

If you do compile the 32-bit version, please check it back into the repository 
so that others can share!