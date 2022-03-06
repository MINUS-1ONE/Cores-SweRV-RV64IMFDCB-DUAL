import os
#filename="./DIV-01.S"
def conv(srcName, outDir):
	insName=srcName.split("\\")[-1][:-5].replace("-", "_").lower()
	outName=outDir+"/"+insName+".S"
	out=open(outName, "w+")
	index=2
	f=open(srcName, "r")
	lines=f.readlines()
	headCode=("# See LICENSE for license details.\n\n"
		"#*****************************************************************************\n")+(
		"# %s.S\n"%(insName))+(
		"#-----------------------------------------------------------------------------\n")+(
		"#\n# Test %s instruction.\n#\n\n"%(insName))+(
		"#include \"riscv_test.h\"\n"
		"#include \"test_macros.h\"\n\n"
		"RVTEST_RV64U\n"
		"RVTEST_CODE_BEGIN\n")
	print(headCode, file=out)

	for line in lines:
		if ("TEST_RR_OP" in line):
			splitList=line.split(',');
			convStr=splitList[0]+","+splitList[4]+","+splitList[5]+","+splitList[6]+");"
			splitList=convStr.split('(');
			convStr=splitList[0]+"(%d, "%(index)+splitList[1]
			index+=1
			print(convStr, file=out)
		elif ("TEST_IMM_OP" in line):
			splitList=line.split(',');
			convStr=splitList[0]+","+splitList[3]+","+splitList[4]+","+splitList[5]+");"
			splitList=convStr.split('(');
			convStr=splitList[0]+"(%d, "%(index)+splitList[1]
			index+=1
			print(convStr, file=out)
	f.close()
	tailCode=("\nTEST_PASSFAIL\n"
	"RVTEST_CODE_END\n"
	"  .data\n"
	"RVTEST_DATA_BEGIN\n"
	"  TEST_DATA\n"
	"RVTEST_DATA_END\n")
	print(tailCode, file=out)
	out.close()

def convFilesInDir(fileDir):
	files=os.listdir(fileDir)
	for file in files:
		if ".S" in file:
			print(fileDir+"\\"+file)
			conv(fileDir+"\\"+file, ".")

convFilesInDir("E:\\githubs\\imperas-riscv-tests-plus\\riscv-test-suite\\rv64i_m\\M\\src")