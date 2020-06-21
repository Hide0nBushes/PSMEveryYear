

*-------------------

*-逐年PSM

*-------------------


* Version 1.0, 2020/6/20
* Author: lehaibo
* 目的：针对多期DID模型，
*       在每一制度年份进行PSM匹配




*-A. 基本设定
  global path "C:\Users\lehai\Desktop\逐年PSM" //定义项目目录 
  global D    "$path\01 Data"      //数据文件
  global Out  "$path\02 Output"       //结果：图形和表格
  cd "$D"                       //设定当前工作路径
  

  
*-D1. 数据导入
  import excel using "$D\PSM.xlsx", first clear
  save "$Out\PSMdata", replace
  
  bys stkcd: gen option_count = sum(option)
  drop if option_count >= 1
  save "$Out\pure_control", replace

*-P1. 采用当年数据进行逐年匹配
  cd "$Out"
  global v   "size-ret_vol" 
  global s1  "$Out\01 CurrentPSM"
  local  x   "rep norep"

  foreach rep in `x'{
 
	  forvalues i = 2007/2018{

		use PSMdata, clear
		preserve

		use PSMdata, clear
		keep if year == `i'   
		local s "$s1\PSM`i'_`rep'"
		set seed 20200620
		gen u = runiform()
		sort u
		
		if "`rep'" == "rep"{
			psmatch2 option $v
		}
		else{
			psmatch2 option $v, norepl
		}

		sort _id
		gen pair = _id if _treated == 0
		replace pair = _n1 if _treated == 1
		bysort pair: egen paircount = count(pair)
		drop if paircount <= 1 

		save "`s'", replace

		keep if option == 1
		qui su year
		dis r(N)

		restore
		qui keep if year == `i' & option == 1
		qui su year
		dis r(N)

	 }
	 clear
	 forvalues i = 2007/2018{

		local s "$s1\PSM`i'_`rep'"
		append using "`s'"
	}

	 pstest $v

	 psgraph
	 graph export "$s1\Current_match_`rep'.png", as(png) replace

	 keep stkcd year option

	 save "$s1\Current_`rep'", replace

  }
 
 




 




*-P2. 采用当年数据进行逐年匹配，纯净控制组
  cd "$Out"
  global v   "size-ret_vol" 
  global s1  "$Out\01 CurrentPSM"
  local  x   "rep norep"

  foreach rep in `x'{
 
	  forvalues i = 2007/2018{

		use PSMdata, clear
		preserve

		use PSMdata, clear
		drop if option == 0
		append using pure_control
		keep if year == `i'   
		local s "$s1\PSM`i'_`rep'_pure"
		set seed 20200620
		gen u = runiform()
		sort u
		
		if "`rep'" == "rep"{
			psmatch2 option $v
		}
		else{
			psmatch2 option $v, norepl
		}

		sort _id
		gen pair = _id if _treated == 0
		replace pair = _n1 if _treated == 1
		bysort pair: egen paircount = count(pair)
		drop if paircount <= 1 

		save "`s'", replace

		keep if option == 1
		qui su year
		dis r(N)

		restore
		qui keep if year == `i' & option == 1
		qui su year
		dis r(N)

	 }
	 clear
	 forvalues i = 2007/2018{

		local s "$s1\PSM`i'_`rep'_pure"
		append using "`s'"
	}

	 pstest $v

	 psgraph
	 graph export "$s1\Current_match_`rep'_pure.png", as(png) replace

	 keep stkcd year option

	 save "$s1\Current_`rep'_pure", replace

  }
 
 
 
 
 