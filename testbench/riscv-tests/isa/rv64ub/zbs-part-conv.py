import os
import re

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
		if ("result rd:" in line):
			p = re.compile(r'[(](.*?)[)]')
			result=re.findall(p, line)
			rd=result[0]
			rs=result[1]
			convStr="	TEST_R_OP(%d, %s, %s, %s);"%(index, insName.replace("_", "."), rd, rs)
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
	validSrc=["CLZ-01.S", "CLZW-01.S", "CPOP-01.S", "CPOPW-01.S", "CTZ-01.S", "CTZW-01.S", 
			"ORC-B-01.S", "REV8-01.S", "SEXT-B-01.S", "SEXT-H-01.S", "ZEXT-H-01.S"]
	files=os.listdir(fileDir)
	for file in files:
		if file in validSrc:
			print(fileDir+"\\"+file)
			conv(fileDir+"\\"+file, ".")

convFilesInDir("E:\\githubs\\imperas-riscv-tests-plus\\riscv-test-suite\\rv64i_m\\Zbb\\src")