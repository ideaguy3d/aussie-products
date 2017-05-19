<%on error resume next%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<% 
Response.ExpiresAbsolute = Now() - 1 
Response.AddHeader "Cache-Control", "must-revalidate" 
Response.AddHeader "Cache-Control", "no-store" 
%> 


<!--#INCLUDE FILE = "include/momapp.asp" -->
<!--#INCLUDE FILE = "CreateXmlObject.asp" -->


<% 

    current_stocknumber = cstr(REQUEST.QUERYSTRING("number"))    
    current_stocknumber =fix_xss_Chars(current_stocknumber)
    
    'current_variation = cstr(REQUEST.QUERYSTRING("variation"))
    'current_variation =fix_xss_Chars(current_variation)
	current_variation=session("Current_selectedVariant")
    
    
    'youselected = request.QueryString("opt")
    
    'response.Write("===youselected -->"&youselected)
    
    
	isvalidstock = sitelink.validstocknumber2(current_stocknumber)
	
	if isvalidstock=-1 then
		set sitelink=nothing
		set ObjDoc=nothing
		Response.Status="301 Moved Permanantly"
		Response.AddHeader "Location", insecureurl&"default.asp"
		Response.End
	end if
  
	SET LOSTOCK =  sitelink.setupproduct(current_stocknumber,cstr(current_variation),0,session("ordernumber"),cstr("")) 
	
	'if len(trim(LOSTOCK.number))= 0 then
	'SET LOSTOCK =  sitelink.setupproduct(cstr(REQUEST.QUERYSTRING("number")),cstr(""),0,session("ordernumber"),cstr(""))
	'end if
	
	has_stock_attribs = LOSTOCK.attribs
  
	bookmarktitle = replace(LOSTOCK.inetsdesc,"'","")
	
	if len(trim(LOSTOCK.META_TITLE)) = 0 then
	    bookmarktitle=bookmarktitle
	else
	    bookmarktitle= trim(LOSTOCK.META_TITLE)
	end if 
	
	'for url rewrite
	if len(trim(LOSTOCK.inetsdesc)) = 0 then 
		usethis_for_urlwrite = URL_CLEANSE(trim(LOSTOCK.NUMBER))
	else
		usethis_for_urlwrite = URL_CLEANSE(trim(LOSTOCK.inetsdesc))
	end if
	
	'session("department") = sitelink.GET_DEPT_FROM_PROD(cstr(current_stocknumber))
	'response.Write(session("department") )
	
	froogle_desc = trim(LOSTOCK.froogle)
	froogle_desc = replace(froogle_desc,"""","")
	froogle_desc = replace(froogle_desc,"<","")
	froogle_desc = replace(froogle_desc,">","")
	
	keylist = trim(LOSTOCK.inetkeywrd)
	keylist = replace(keylist,"""","")
	keylist = replace(keylist,"<","")
	keylist = replace(keylist,">","")
	
	set SL_ProdInfoDetails = New cProductInfoDetailsObj
	
	SL_ProdInfoDetails.lnumber=cstr(current_stocknumber)
	SL_ProdInfoDetails.lVariant=cstr(current_variation)
	SL_ProdInfoDetails.lOrderNumber=session("ordernumber")
	SL_ProdInfoDetails.lShopperID=session("shopperid")
	SL_ProdInfoDetails.lShowExpectedDate=SHOW_DUE_DATE
	
	call sitelink.GET_SLSTOCK_DETAILS(SL_ProdInfoDetails)
	
	SL_SizeColorXmlStream = SL_ProdInfoDetails.lSizeColorXmlStream
	SL_SpecialPriceXmlStream = SL_ProdInfoDetails.lSpecialPriceXmlStream
	exp_date = SL_ProdInfoDetails.lExpectedDate
	
	SL_CrossSellXmlStream = SL_ProdInfoDetails.lCrossSellXmlStream
	optcodexmlstring = SL_ProdInfoDetails.lst_optcode
	optvalxmlstring = SL_ProdInfoDetails.lst_optval
	optskuxmlstring = SL_ProdInfoDetails.lst_optsku
	optakuFirstCodestring = SL_ProdInfoDetails.lst_optfirstsku
	StockAttrib_MinPrice = SL_ProdInfoDetails.lStockMinPrice
	StockAttrib_MaxPrice = SL_ProdInfoDetails.lStockMaxPrice
	Has_Subs_ForDiscont  = SL_ProdInfoDetails.lHas_Subs_ForDiscont		
	
%>

<html>
<head>
<title><%=trim(bookmarktitle)%>-<%=althomepage%></title>
<meta NAME="KEYWORDS" CONTENT="<%=keylist%>">
<meta NAME="description" CONTENT="<%=froogle_desc%>">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<% if request.servervariables("server_port_secure") = 1 then %>
	<base href="<%=secureurl%>">
<% else %>
	<base href="<%=insecureurl%>">
<% end if %>

<link rel="stylesheet" href="text/topnav.css" type="text/css">
<link rel="stylesheet" href="text/sidenav.css" type="text/css">
<link rel="stylesheet" href="text/storestyle.css" type="text/css">
<link rel="stylesheet" href="text/footernav.css" type="text/css">
<link rel="stylesheet" href="text/design.css" type="text/css">
<script type="text/javascript" language="JavaScript" src="calender_old.js"></script>
<script type="text/javascript" language="JavaScript" src="prodinfo.js"></script>
<script type="text/javascript" language="javascript">
function RedirectToAddADDress (lvalue,stockid,dropdownnum,needurlrewrite,rewritedesc){
     var new_url="" ;
     var addparam ="" ;
     for( var i = 1 ; i <= dropdownnum ; i++){
      var attribtype = "slopttype"+i ;
      attribtype = "document.getElementById('"+attribtype+"').value" ;
      attribtypeval = eval(attribtype)
      if (attribtypeval=="D"){
        var Prodattribname = "Attrib"+i ;
        var Prodattribevalname = "document.getElementById('"+Prodattribname+"').selectedIndex" ;
        selIndex= eval(Prodattribevalname) ;
        Prodattribevalname = "document.getElementById('"+Prodattribname+"').options["+selIndex+"].value" ;
        var selIndexvalue = eval(Prodattribevalname) 
      }//if (attribtypeval=="D")
      if (attribtypeval=="R"){
        attribradio = eval("prodinfoform.Attrib"+i+".length") ;
        j = attribradio
        for (k=0; k<j; k++){
            radiochecked = eval("prodinfoform.Attrib"+i+"["+k+"].checked") ;
             if (radiochecked){
                selIndexvalue = eval("prodinfoform.Attrib"+i+"["+k+"].value") ;               
             }
        }
      } //if (attribtypeval=="R")
      if (i==1){
        addparam = selIndexvalue
        }
        else{
        addparam = addparam + "|"+selIndexvalue
        }
     }
    if (needurlrewrite==1){
		new_url = "<%=insecureurl%>"+ rewritedesc + "/productinfo/" + stockid  + "/" + addparam 
		}
	else{	
	    new_url = "prodinfo.asp?number="+stockid+"&opt="+addparam
		}
    window.location=new_url;
}
function GoToAddADDress (page)
   {
	var new_url = '<%=insecureurl%>'+page
   //if (  (new_url != "")  &&  (new_url != null)  )
    window.location=new_url;
	//alert(new_url)
   }
</script>
</head>
<!--#INCLUDE FILE = "text/Background5.asp" -->



<div id="container">
    <!--#INCLUDE FILE = "include/top_nav.asp" -->
    <div id="main">

<% 
	session("destpage")="prodinfo.asp?number="+cstr(current_stocknumber) 
	session("viewpage")=session("destpage")

%>



<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
	
<td width="<%=SIDE_NAV_WIDTH%>" class="sidenavbg" valign="top">
<!--#INCLUDE FILE = "include/side_nav.asp" -->
	</td>	
	<td valign="top" class="pagenavbg">

<!-- sl code goes here -->
<div id="page-content">
	
	<%if session("department")= "-1" then %>	
	<table width="98%"  cellpadding="3" cellspacing="0" border="0">
		<tr><td class="breadcrumbs"><a href="<%=insecureurl%>default.asp"><font class="breadcrumb-link">Home</font></a><span class="breadcrumb-divide">&nbsp;&nbsp;&#47;&nbsp;&nbsp;</span><a href="<%=insecureurl%>specials.asp" title="Specials"><font class="breadcrumb-link">Specials</font></a></td></tr>
	</table>
	<%end if %>
	
	
	<%if session("department") > 0 then %>
	<table width="98%"  cellpadding="3" cellspacing="0" border="0">
				<tr><td class="breadcrumbs" width="100%">
						<a class="allpage" href="default.asp"><font class="breadcrumb-link">Home</font></a><span class="breadcrumb-divide">&nbsp;&nbsp;&#47;&nbsp;&nbsp;</span>
						<%
						deptstr = sitelink.deptstring(session("department"),true,"<span class='breadcrumb-divide'>&nbsp;&nbsp;&#47;&nbsp;&nbsp;</span>","breadcrumb-link","",WANT_REWRITE)
						if WANT_REWRITE=1 then
						    targetstr = "departments/"+cstr(session("department"))
						    str_replace = "products/"+cstr(session("department"))
						    deptstr = replace(deptstr,targetstr,str_replace)
						else
						    targetstr = "departments.asp?dept="+cstr(session("department"))
						    str_replace = "products.asp?dept="+cstr(session("department"))
						    deptstr = replace(deptstr,targetstr,str_replace)
						end if
						%>
						<%=deptstr%>
					</td>
				</tr>
	</table>
	<%end if%>
	<br>
	
	<table width="98%"  BORDER="0" cellpadding="3" cellspacing="0">
		<tr><td><H1><%=trim(LOSTOCK.inetsdesc)%></H1></td></tr>				
	</table>
	<br>
		
	<form enctype="application/x-www-form-urlencoded" method="post" name="prodinfoform" onSubmit="return Process()" action="itemadd.asp">
	<table width="98%"  cellpadding="0" cellspacing="0" border="0">
	
	        <tr> 
              <td width="50%" valign="top"> 
			  <center>
                <% StrFileName = "images/"+trim(LOSTOCK.inetimage)
				StrPhysicalPath = Server.MapPath(StrFileName)
			  set objFileName = CreateObject("Scripting.FileSystemObject")	
			  if objFileName.FileExists(StrPhysicalPath) then
		       		imagename=StrFileName
			  else
					imagename="images/noimage.gif"
  			  end if
			  set objFileName = nothing
			%>
                <img SRC="<%=imagename%>" alt="<%=trim(LOSTOCK.inetsdesc)%>" title="<%=trim(LOSTOCK.inetsdesc)%>" hspace="5" border="0" align="middle"> 
               <%
				'view large image
				found = false
				'check for invalid character.
				
				Has_invalid_char= false 
				firstchar = left(current_stocknumber,1)
				
				select case firstchar
					case "\","/",":","?","*","""","<",">","|",";"
						Has_invalid_char=true					
				end select
											
				if Has_invalid_char = true then
					 found=false
				else				
					StrFileName = "images/"+cstr(current_stocknumber) +"-Large.jpg"
					StrPhysicalPath = Server.MapPath(StrFileName)
					set objFileName = CreateObject("Scripting.FileSystemObject")	
					if objFileName.FileExists(StrPhysicalPath) then
			     			largeimagename=insecureurl + StrFileName
							found = true
					else
						largeimagename="images/noimage.gif"
						found = false
	  				end if
					set objFileName = nothing		
				end if
				  
				 	
			%>
                <script type="text/javascript" language="javascript">
			function ShowlargeImage(whatimage)
				{
				whatimage =whatimage		 
				 popupWin = window.open(whatimage, '', 'scrollbars,resizable,width=500,height=450');
				}//-->
			</script>
                <% if found = true then %>
                <br>
               
                <center>
                  <a class="allpage" href="javascript:ShowlargeImage('<%=largeimagename%>')"><font color="red"><u><b>View 
                  Large Image</b></u></font></a> 
                </center>
                <%end if%>

				<%
				 has_addtionalimage = false
				 if len(trim(LOSTOCK.sl_image1)) > 0 or len(trim(LOSTOCK.sl_image2)) > 0 or len(trim(LOSTOCK.sl_image3)) > 0 or len(trim(LOSTOCK.sl_image4)) > 0 or len(trim(LOSTOCK.sl_image5)) > 0 or len(trim(LOSTOCK.sl_image6)) > 0 or len(trim(LOSTOCK.sl_image7)) > 0 or len(trim(LOSTOCK.sl_image8)) > 0 then
				 	has_addtionalimage=true
				 end if
				 
				 if has_addtionalimage=true then				 
				%>
				<br><br>
								
				<a href="javascript:ShowAddtionalImage('<%=insecureurl%>','<%=current_stocknumber%>')"><img src="images/btn-addtnl-images.gif" border="0"></a>
				<%end if%>
					</center>


              </td>
			                
                <td width="50%" valign="top">
					<input type="hidden" name="addtocart" id="addtocart"><input type="hidden" name="addtowishlist" id="addtowishlist">
					<input type="hidden" name="additem" value="<%=current_stocknumber%>">					

					<table width="100%" border="0"  cellpadding="8" cellspacing="0"
					style="BORDER-RIGHT: #CCCCCC 1px solid  ; 
	    	            BORDER-TOP: #CCCCCC 1px solid  ; 
			            BORDER-LEFT: #CCCCCC 1px solid  ; 
			            BORDER-BOTTOM: #CCCCCC 1px solid "
					>					
						<tr><td class="tdRow1Color" width="100%">
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
							
							
								<tr><td class="plaintextbold">Item Number:&nbsp;<%=current_stocknumber%></td></tr>
								
							<tr><td><img alt="" src="images/clear.gif" width="1" height="5" border="0"></td></tr>
							<%
							
								'SL_prefShip_Title = ""
							    'SL_prefShip_Method = trim(LOSTOCK.prefship)
								'if len(SL_prefShip_Method) > 0 then
									SL_prefShip_Title=SL_ProdInfoDetails.lPrefShipMethod
								'end if
								
							  if LOSTOCK.size_color = true then
							  	 extra_field = ""					 			
								 objDoc.loadxml(SL_SizeColorXmlStream)									
								set SL_sbcl = objDoc.selectNodes("//sbcl") 
							  end if 
															
							  has_Onespecial_Price=false
							  extra =""
							  AllSpecialXmlstring = SL_SpecialPriceXmlStream							  
							  objDoc.loadxml(SL_SpecialPriceXmlStream)
							  							  
							  set SL_gsp = objDoc.selectNodes("//gsp")
							  
							  tnode = "//gsp[qty=1 and total_dol <="+cstr(cdbl(session("SL_BasketSubTotal")))+"]"
							  Set SL_QtyOnePricing = objDoc.selectNodes(tnode)
							  
							  
							  if SL_QtyOnePricing.length > 0 then
									SL_SP_price = SL_gsp.item(0).selectSingleNode("price").text
									SL_SP_discount = SL_gsp.item(0).selectSingleNode("discount").text
									
									SL_SP_CostMeth = SL_gsp.item(0).selectSingleNode("costmethod").text
									SL_SP_CostPlusDiscount = SL_gsp.item(0).selectSingleNode("costplus").text
									SL_SP_StockReOrdPrice = SL_gsp.item(0).selectSingleNode("reordprice").text
									SL_SP_UnCostprice = SL_gsp.item(0).selectSingleNode("uncost").text
									
									if SL_SP_CostMeth="" then
										unitprice = LOSTOCK.price1
										unitprice2 = SL_SP_price
										if unitprice2>0 then
											unitprice = unitprice2
										end if
										percentoff = (SL_SP_discount/100.0)
										discountedUnitPrice = cdbl(unitprice * (1- percentoff))									
									end if
									
									if SL_SP_CostMeth="P" then
										discountedUnitPrice= cdbl(SL_SP_StockReOrdPrice*(1+SL_SP_CostPlusDiscount/100.0))
									end if
									
									if SL_SP_CostMeth="U" then										
										discountedUnitPrice= cdbl(SL_SP_UnCostprice*(1+SL_SP_CostPlusDiscount/100.0))									
									end if
																											
									has_Onespecial_Price=true
								end if
								
								set SL_QtyOnePricing=nothing
								
								set SL_gsp = nothing
								
							objDoc.loadxml(AllSpecialXmlstring)
							set SL_gsp = objDoc.selectNodes("//gsp[qty>1]")
							
							%>
							<%if LOSTOCK.size_color = false then %>
							<tr><td class="ProductPrice">
								<%if has_Onespecial_Price=true then %>
								<table>
								 <tr><td class="ProductPrice">
								 		Unit Price: <s><%=FORMATCURRENCY(LOSTOCK.price1)%></s>
								 	</td>
								  </tr>
								  <tr>
									<td>
									<table cellpadding="0" cellspacing="0" border="0">
									<tr><td class="nopadding"><img src="images/RedSaleTag.gif" style="border:0;width=53;height:23;"></td>
										<td class="plaintext nopadding" align="center" style="background-image:url(images/RedSaleTag_bkg.gif);height:23">
										<span style="font-weight:bold;color:White;"><%=formatcurrency(discountedUnitPrice)%></span>&nbsp;
										</td>
									</tr>
									</table>
									
									</td>
								</tr>
								</table>
							   <%else%>
							   	Unit Price: <%=FORMATCURRENCY(LOSTOCK.price1)%>
							   <%end if%>
							</td></tr>
							<%end if%>
							
							
							<%if SHOW_COMP_PRICE="TRUE" and LOSTOCK.inetcprice > 0 then %>
								<tr><td class="CompPrice">Compare At: <%=FORMATCURRENCY(LOSTOCK.inetcprice)%></td></tr>
							<%end if%>

							<%
							

							  'if SL_gsp.length > 0 and has_Onespecial_Price=false then 
							  if SL_gsp.length > 0 and has_stock_attribs=false then %>
							  <tr><td><img alt="" src="images/clear.gif" width="1" height="5" border="0"></td></tr>
							  <tr><td valign="top">

							  <table width="100%" border="0" cellspacing="1" cellpadding="1">
							   <tr><td class="THHeader" colspan="3">Special Pricing</td></tr>
							   <%

								for x=0 to SL_gsp.length-1
									'SL_SP_Number = SL_gsp.item(x).selectSingleNode("number").text
									SL_SP_qty = SL_gsp.item(x).selectSingleNode("qty").text
									'if SL_SP_qty > 1 then
									SL_SP_price = SL_gsp.item(x).selectSingleNode("price").text
									SL_SP_discount = SL_gsp.item(x).selectSingleNode("discount").text
									SL_SP_ordertotal = SL_gsp.item(x).selectSingleNode("total_dol").text
									SL_SP_desc2 = SL_gsp.item(x).selectSingleNode("desc2").text
									SL_SP_CostMeth = SL_gsp.item(x).selectSingleNode("costmethod").text
									SL_SP_CostPlusDiscount = SL_gsp.item(x).selectSingleNode("costplus").text
									SL_SP_StockReOrdPrice = SL_gsp.item(x).selectSingleNode("reordprice").text
									SL_SP_UnCostprice = SL_gsp.item(x).selectSingleNode("uncost").text
									
									if LOSTOCK.size_color=false then
											SL_SP_desc2=""
									end if 
									
									SL_SP_qty = replace(SL_SP_qty,".00","")
									
									if SL_SP_CostMeth="" then
										unitprice = LOSTOCK.price1
										unitprice2 = SL_SP_price
										if unitprice2>0 then
											unitprice = unitprice2
										end if
										percentoff = (SL_SP_discount/100.0)
										discountedUnitPrice = cdbl(unitprice * (1- percentoff))									
									end if
									
									if SL_SP_CostMeth="P" then
										discountedUnitPrice= cdbl(SL_SP_StockReOrdPrice*(1+SL_SP_CostPlusDiscount/100.0))
									end if
									
									if SL_SP_CostMeth="U" then										
										discountedUnitPrice= cdbl(SL_SP_UnCostprice*(1+SL_SP_CostPlusDiscount/100.0))									
									end if
																		
									if (x mod 2) = 0 then
										 class_to_use = "tdRow1Color"
									else
										class_to_use = "tdRow2Color"
									end if 
										
									threshholdTxt = ""
									if SL_SP_ordertotal > 0 then
										threshholdTxt= "&nbsp;for order over "+formatcurrency(SL_SP_ordertotal)
									end if
									
								%>
								<tr>
								<td class="<%=class_to_use%>"><span class="plaintext">&nbsp;Buy&nbsp;<%=SL_SP_qty%>&nbsp;<%=SL_SP_desc2%>&nbsp;for&nbsp;<%=formatcurrency(discountedUnitPrice)%>&nbsp;each<%=threshholdTxt%></span></td>
								</tr>
								
							<%
							'end if
							next %>
							  </table>
							  </td>
							  </tr>
							  
							  <%end if %>
							  
							  <%
							 
							  if SHOW_IN_STOCK =1 and LOSTOCK.size_color = false then 
								avail_status = "In Stock"
					  			if (LOSTOCK.units > 0) or (LOSTOCK.dropship = true) or (LOSTOCK.construct = true) then
									avail_status="In Stock"
							  	else
									if SHOW_DUE_DATE = 1 then									    
											if IsDate(exp_date) = false then
												avail_status="Out of Stock"
											else
											     avail_status="Expected on : "+ exp_date
											end if
									else
										avail_status="Out of Stock"
									end if
								end if
								%>
								<tr><td><img alt="" src="images/clear.gif" width="1" height="5" border="0"></td></tr>
								<tr><td class="plaintextbold"><%=avail_status%></td></tr>
								<%
								end if
								%>

							 <%'if len(trim(LOSTOCK.prodavail)) > 0 then %>
							  <tr><td class="plaintext"><%=LOSTOCK.prodavail%></td></tr>
							 <%'end if%>					
							<tr><td><img alt="" src="images/clear.gif" width="1" height="5" border="0"></td></tr>
							<% if SL_prefShip_Title<>"" then %>
							<tr><td class="plaintext"><br>Will be shipped via: <%=SL_prefShip_Title%></td></tr>
							<%end if%>
							
							<% 							 
							if LOSTOCK.size_color = true and has_stock_attribs=false then %>
							<tr><td class="THHeader">Size/Color</td></tr>
							<tr><td>
							
							<select NAME="txtvariantVar" class="smalltextblk" onChange="GoToAddADDress(this.options[this.selectedIndex].value)">
							
							<%
								 for x=0 to SL_sbcl.length-1
									SL_Variation= SL_sbcl.item(x).selectSingleNode("scolor").text
									SL_VarationDesc= SL_sbcl.item(x).selectSingleNode("desc2").text
									SL_VarationPrice= SL_sbcl.item(x).selectSingleNode("price1").text
									SL_VarationUnits= SL_sbcl.item(x).selectSingleNode("units").text
									SL_VarationDrop= SL_sbcl.item(x).selectSingleNode("dropship").text
									SL_VarationConst= SL_sbcl.item(x).selectSingleNode("construct").text
									
									target_in_SpecialPrice = "//gsp[number2='"+cstr(SL_Variation)+"' and qty=1 and total_dol <="+cstr(cdbl(session("SL_BasketSubTotal")))+"]"
									set SP_PriceObj = ObjDoc.selectNodes(target_in_SpecialPrice)
									if SP_PriceObj.length > 0 then										
											SL_SP_price = SP_PriceObj.item(0).selectSingleNode("price").text
											SL_SP_discount = SP_PriceObj.item(0).selectSingleNode("discount").text

											unitprice = SL_VarationPrice
											unitprice2 = SL_SP_price
											if unitprice2>0 then
												unitprice = unitprice2
											end if
											percentoff = (SL_SP_discount/100.0)
											discountedUnitPrice = cdbl(unitprice * (1- percentoff))
											SL_VarationPrice=discountedUnitPrice
									end if

									set SP_PriceObj =nothing
										
									if WANT_REWRITE =1 then
										addthisurl = "&addthis="+ bookmarktitle
									else
										addthisurl=""
									end if	
									if x= 0 then
							           usethisvariation = SL_Variation							        
							        end if						
										
								 %>
							<option value="getvariation.asp?number=<%=current_stocknumber%>&whatvar=<%=SL_Variation%><%=addthisurl%>"
								<% if current_variation = cstr(SL_Variation) then response.write(" selected") end if%>							
							>
							<%=SL_VarationDesc%>&nbsp;<%=formatcurrency(SL_VarationPrice)%>
							<%if SHOW_IN_STOCK =1 then
								if (SL_VarationUnits > 0) or (SL_VarationDrop = "true") or (SL_VarationConst = "true") then								
						      		Response.Write(" - In Stock")
								 else
								       Response.Write(" - Out of Stock")
								  end if 	
							  end if
							 %>
							 <%
							 next
							 set SL_sbcl = nothing
							
							 %>		
							</select>
							<%
							 if len(trim(current_variation)) > 0  then
							          usethisvariation = current_variation
 					        end if
							
							 %>
							<input type="hidden" name="txtvariant" value="<%=usethisvariation%>">
							</td></tr>
							<%end if%>
							
							
							<%if has_stock_attribs=true then								
								'set SLProdAttribObj = New cProductAttribObj
								'SLProdAttribObj.lnumber= cstr(current_stocknumber)
								
								
								'call sitelink.GET_SLSTOCK_ATTRIBUTE(SLProdAttribObj)
								
								'optcodexmlstring = SLProdAttribObj.lst_optcode
								'optvalxmlstring = SLProdAttribObj.lst_optval
								'optskuxmlstring = SLProdAttribObj.lst_optsku
								'optakuFirstCodestring = SLProdAttribObj.lst_optfirstsku
								'StockAttrib_MinPrice = SLProdAttribObj.lStockMinPrice
								'StockAttrib_MaxPrice = SLProdAttribObj.lStockMaxPrice
								
								'set SLProdAttribObj =nothing
								
								objDoc.loadxml(optcodexmlstring)
								target_optcodenode ="//loptcode[opttype!='T' and skulink='true']"
								set SL_optcode = objDoc.selectNodes(target_optcodenode) 								
								maxoption = SL_optcode.length-1
								'set SL_optcode = nothing
								
								'target_optcodenodeNONSku ="//loptcode[opttype='T']"
								target_optcodenodeNONSku ="//loptcode[skulink='false']"
								set SL_optcodeNONSku = objDoc.selectNodes(target_optcodenodeNONSku)
								maxTextoption = SL_optcodeNONSku.length-1
								'set SL_optcodeNONSkue = nothing
								
								'response.Write(maxoption)
								
								'target_optcodenode ="//loptcode"								
								'set SL_optcode = objDoc.selectNodes(target_optcodenode) 
								
								
								'init all request.quertstring.
								
								current_selection = request.QueryString("opt")
								
								for x=1 to maxoption								    
								    session("Current_AttribSelected"&x)=""							
								next 
								
								MyArray = Split(current_selection, "|", -1, 1)
								dim initselect	
								x=1								
								for each initselect in MyArray								
								    session("Current_AttribSelected"&x)=initselect								    
								    x=x+1
								  
								next
								
								'for x=1 to maxoption								    
								'    response.write("prodoptionval -->"&session("Current_AttribSelected"&x) &"<br>")					
								'next 
								'response.Write("<br>=====================<br>")
								
								for x=0 to SL_optcode.length-1
									sloptcode = SL_optcode.item(x).selectSingleNode("optcode").text									
									slopttitle = SL_optcode.item(x).selectSingleNode("opttitle").text
									slopttype = SL_optcode.item(x).selectSingleNode("opttype").text
									sloptlen = SL_optcode.item(x).selectSingleNode("vallen").text
									
								 
							%>
								<tr><td class="plaintextbold">
								<table border="0">
								<tr><td class="plaintextbold" valign="top"><%=slopttitle%>
								<input type="hidden" name="slopttype<%=(x+1)%>" id="slopttype<%=(x+1)%>" value="<%=slopttype%>">
								<input type="hidden" name="SkuAttribTitle<%=(x+1)%>" id="SkuAttribTitle<%=(x+1)%>" value="<%=slopttitle%>">
								
								</td>
								<td valign="top">																
								
								<%
								
								current_selectionlen = len(trim(current_selection))
								
								valfilter =""
								if current_selectionlen > 0 then	
								
								    matchonlythis = ""
								    
								    for m=1 to x
								      matchonlythis = matchonlythis + session("Current_AttribSelected"&m) + "|"								    
								    next
								    matchonlythislen =len(matchonlythis)
								    		
								    newcurrent_selection = cstr(current_selection) + "|"					    								    
								    target_node = "//loptsku[optskukey[substring(.,1,"+cstr(matchonlythislen)+")='"+cstr(matchonlythis)+"']]"								    
    								objDoc.loadxml(optskuxmlstring)
								
								
								set SL_optsku = objDoc.selectNodes(target_node) 
								    for z= 0 to SL_optsku.length-1
								        sl_opskukey = SL_optsku.item(z).selectSingleNode("optskukey").text
								        MyArray = Split(sl_opskukey, "|", -1, 1)
								        sl_opskukey = "optvalkey = " + cstr(MyArray(x)) + " and opttitle='"+slopttitle+"'"
								        sl_opskukey = "(" + sl_opskukey + ")"
								        valfilter = valfilter + sl_opskukey + " or "
								    next   
								set SL_optsku= nothing
								
								end if
								
								lenvalfilter = len(valfilter)
								
								if lenvalfilter > 0 then								
								    valfilter = mid(valfilter,1, len(valfilter)-3)
								    'valfilter = valfilter + " and opttitle='"+slopttitle+"'"
								end if
								 %>
								 
								 <%if slopttype="D" then%>
								 <select name="Attrib<%=(x+1)%>" id="Attrib<%=(x+1)%>" <%if  x < maxoption then %> onChange="RedirectToAddADDress(this.options[this.selectedIndex].value,'<%=current_stocknumber%>',<%=x+1%>,<%=WANT_REWRITE%>,'<%=usethis_for_urlwrite%>')" <%end if%>>
								 <option value="">Select 
								 <%
								 
								 if x=0 then
								    objDoc.loadxml(optakuFirstCodestring)
								    target_node = "//firstoptsku[opttitle='"+cstr(slopttitle)+"']"
								    set SL_optvalsku = objDoc.selectNodes(target_node) 
								    
								 else	
								    if lenvalfilter > 0 then	
								        objDoc.loadxml(optvalxmlstring)
								        target_node = "//loptval["+valfilter+"]"	
								        'response.Write(target_node)							        
								        set SL_optvalsku = objDoc.selectNodes(target_node)
								    end if 
								 
								 end if 
								 
								 if lenvalfilter > 0 or x=0 then
								    for y= 0 to SL_optvalsku.length-1 
								    sloptvalue = SL_optvalsku.item(y).selectSingleNode("optvalue").text
								    sloptvalkey = SL_optvalsku.item(y).selectSingleNode("optvalkey").text
								    sloptprice = SL_optvalsku.item(y).selectSingleNode("optprice").text
								    
								    
								    
								    additionalPrice= ""
								    if sloptprice > 0 then
								        sloptprice =formatcurrency(sloptprice)
								        additionalPrice = "(+" + cstr(replace(sloptprice,".00","")) + ")"								  
								    end if 
								    if sloptprice < 0 then
								        sloptprice =formatcurrency(sloptprice)
								        additionalPrice =  cstr(replace(sloptprice,".00","")) 
								        additionalPrice =  replace(additionalPrice,"(","(-")
								    end if
								    
								    
								  %>
								  <option value="<%=sloptvalkey%>" <%if session("Current_AttribSelected"&(x+1)) = sloptvalkey then response.write(" selected") end if%>>
								  <%=sloptvalue%> <%=additionalPrice%>
								  <%next%>
								 
								 <%end if 'if lenvalfilter > 0 or x=0 then%>
								
								 </select>
								<%
								end if 'if slopttype="D"  %>
								
								<%if slopttype="R" then%>
								<% 
								 
								 if x=0 then
								    
								    objDoc.loadxml(optakuFirstCodestring)
								    target_node = "//firstoptsku[opttitle='"+cstr(slopttitle)+"']"
								    set SL_optvalsku = objDoc.selectNodes(target_node) 								    
								 else	
								    if lenvalfilter > 0 then	
								        objDoc.loadxml(optvalxmlstring)
								        target_node = "//loptval["+valfilter+"]"		
								        'response.Write(target_node)						        
								        set SL_optvalsku = objDoc.selectNodes(target_node)
								    end if 
								 
								 end if 
								 
								 
								 
								 if lenvalfilter > 0 or x=0 then
								    for y= 0 to SL_optvalsku.length-1 
								    sloptvalue =  SL_optvalsku.item(y).selectSingleNode("optvalue").text
								    sloptvalkey = SL_optvalsku.item(y).selectSingleNode("optvalkey").text
								    sloptprice = SL_optvalsku.item(y).selectSingleNode("optprice").text
								    
								    additionalPrice= ""
								    if sloptprice > 0 then
								        sloptprice =formatcurrency(sloptprice)
								        additionalPrice = "(+" + cstr(replace(sloptprice,".00","")) + ")"								  
								    end if 
								    if sloptprice < 0 then
								        sloptprice =formatcurrency(sloptprice)
								        additionalPrice =  cstr(replace(sloptprice,".00","")) 
								        additionalPrice =  replace(additionalPrice,"(","(-")
								    end if
								    
								%>
								    
								    <input type="hidden" name="noradio<%=(x+1)%>" id="noradio<%=(x+1)%>" value="1">
								    <input type="radio" name="Attrib<%=(x+1)%>" id="Attrib<%=(x+1)%>" value="<%=sloptvalkey%>" <%if session("Current_AttribSelected"&(x+1)) = sloptvalkey then response.write(" checked") end if%> <%if  x < maxoption then %> onClick="RedirectToAddADDress(<%=sloptvalkey%>,'<%=current_stocknumber%>',<%=x+1%>,<%=WANT_REWRITE%>,'<%=usethis_for_urlwrite%>')" <%end if%>>
								    <span class="plaintext"><%=sloptvalue%>
								    &nbsp;<%=additionalPrice %>
								    </span>
								    <%next%>
								<%end if %>
								    <input type="hidden" name="noradio<%=(x+1)%>"  id="noradio<%=(x+1)%>" value="0">
								<%'end if 'if lenvalfilter > 0 or x=0 then%>
								
								<%end if 'if slopttype="R" %>
								
								
								<%
								set SL_optvalsku=nothing
								set SL_optval = nothing
								
								%>
								
								</td></tr>
								</table>
																	
								</td></tr>
							
							<%next
							set SL_optcode=nothing 
							%>
							<% 
								for x=0 to SL_optcodeNONSku.length-1 
									sloptcode = SL_optcodeNONSku.item(x).selectSingleNode("optcode").text									
									slopttitle = SL_optcodeNONSku.item(x).selectSingleNode("opttitle").text
									slopttype = SL_optcodeNONSku.item(x).selectSingleNode("opttype").text
									sloptlen = SL_optcodeNONSku.item(x).selectSingleNode("vallen").text
									sloptvaltype = SL_optcodeNONSku.item(x).selectSingleNode("valtype").text
									sloptvalDes = SL_optcodeNONSku.item(x).selectSingleNode("valdec").text
									
									if sloptvaltype="D" then
										sloptlen=10										
									end if
									
									if sloptvaltype<>"N" then
										sloptvalDes=0
									end if
							%>
							<tr><td class="plaintextbold">
								<table border="0">
								<tr><td class="plaintextbold" valign="top"><%=slopttitle%>
								<input type="hidden" name="NonSkuslopttype<%=(x+1)%>" id="NonSkuslopttype<%=(x+1)%>" value="<%=slopttype%>">
								<input type="hidden" name="NonSkuAttribTitle<%=(x+1)%>" id="NonSkuAttribTitle<%=(x+1)%>" value="<%=slopttitle%>">
								<input type="hidden" name="NonSkusvaltype<%=(x+1)%>" id="NonSkusvaltype<%=(x+1)%>" value="<%=sloptvaltype%>">
								<input type="hidden" name="NonSkuNumericBeforeDec<%=(x+1)%>" id="NonSkuNumericBeforeDec<%=(x+1)%>" value="<%=sloptlen%>">
								<input type="hidden" name="NonSkuNumericAfterDec<%=(x+1)%>" id="NonSkuNumericAfterDec<%=(x+1)%>" value="<%=sloptvalDes%>">
								</td>
								<td valign="top" class="plaintext">
								
								 <%if sloptvaltype="N" then %>
								 	<input type="text" name="NonSkuAttribtext<%=(x+1)%>" id="NonSkuAttribtext<%=(x+1)%>" maxlength="<%=sloptlen+1%>" size="10" class="plaintext" onBlur="extractNumber(this,0,true);" onKeyUp="extractNumber(this,0,true);" onKeyPress="return blockNonNumbers(this, event, false, true,<%=sloptlen%>);">									
								 	<%if sloptvalDes > 0 then%>
										 <input type="text" name="NonSkuAttribtextDec<%=(x+1)%>" id="NonSkuAttribtextDec<%=(x+1)%>" maxlength="<%=sloptvalDes+1%>" size="10" class="plaintext" onBlur="extractNumber(this,0,false);" onKeyUp="extractNumber(this,0,false);" onKeyPress="return blockNonNumbers(this, event, false, false,<%=sloptvalDes%>);">			
										<%end if%>
									&nbsp;(Numeric Values Only)
								 <%end if%>
								 
								 
								 <%if sloptvaltype="D" then %>
								 	<input type="text" name="NonSkuAttribtext<%=(x+1)%>" id="NonSkuAttribtext<%=(x+1)%>" maxlength="<%=sloptlen%>" size="10" class="plaintext">
								   <a href="javascript:show_calendar('prodinfoform.NonSkuAttribtext<%=(x+1)%>');"><img src="images/calendarSm.gif" border="0" align="center" WIDTH="25" HEIGHT="19"></a>
								 <%end if%>
								 
								 <%if sloptvaltype="C" then %>
								 	<input type="text" name="NonSkuAttribtext<%=(x+1)%>" id="NonSkuAttribtext<%=(x+1)%>" maxlength="<%=sloptlen%>" size="10" class="plaintext">
								 
								 <%end if%>
								
									<%if slopttype="D" then%>
										<select name="NonSkuAttribtext<%=(x+1)%>">
										    <option value="">Select</option>
										<%
										    objDoc.loadxml(optvalxmlstring)										   
										    target_node = "//loptval[optcode='"+cstr(sloptcode)+"' and opttitle='"+cstr(slopttitle)+"']"
										    set sl_optvalnode = objDoc.selectNodes(target_node)
										    for y= 0 to sl_optvalnode.length-1 
										        optvaluenode = sl_optvalnode.item(y).selectSingleNode("optvalue").text
												sloptprice   = sl_optvalnode.item(y).selectSingleNode("optprice").text
												sloptpriceval = sloptprice
												additionalPrice= ""
												if sloptprice > 0 then
													sloptprice =formatcurrency(sloptprice)
													additionalPrice = "(+" + cstr(replace(sloptprice,".00","")) + ")"								  
												end if 
												if sloptprice < 0 then
													sloptprice =formatcurrency(sloptprice)
													additionalPrice = cstr(replace(sloptprice,".00","")) 
													additionalPrice = replace(additionalPrice,"(","(-")
												end if

										 %>
										    <option value="<%=optvaluenode%>|<%=sloptpriceval%>"><%=optvaluenode %><%=additionalPrice%></option>
										    
										    <%next
										    set sl_optvalnode=nothing
										    %>
										</select>								
									<%end if%>
									<%if slopttype="R" then%>
									    <%
										    objDoc.loadxml(optvalxmlstring)
										    'target_node = "//loptval[optcode='"+cstr(sloptcode)+"']"
											target_node = "//loptval[optcode='"+cstr(sloptcode)+"' and opttitle='"+cstr(slopttitle)+"']"
										    set sl_optvalnode = objDoc.selectNodes(target_node)
										    for y= 0 to sl_optvalnode.length-1 
										        optvaluenode = sl_optvalnode.item(y).selectSingleNode("optvalue").text
												sloptprice   = sl_optvalnode.item(y).selectSingleNode("optprice").text
												sloptpriceval = sloptprice
												 additionalPrice= ""
												if sloptprice > 0 then
													sloptprice =formatcurrency(sloptprice)
													additionalPrice = "(+" + cstr(replace(sloptprice,".00","")) + ")"								  
												end if 
												if sloptprice < 0 then
													sloptprice =formatcurrency(sloptprice)
													additionalPrice = cstr(replace(sloptprice,".00","")) 
													additionalPrice = replace(additionalPrice,"(","(-")
												end if
										 %>
										<input type="radio" name="NonSkuAttribtext<%=(x+1)%>" id="NonSkuAttribtext<%=(x+1)%>" value="<%=optvaluenode%>|<%=sloptpriceval%>"><%=optvaluenode %>&nbsp;<%=additionalPrice %>
										<%next
								        set sl_optvalnode=nothing
								        %>
									<%end if%>
								</td>
								</table>
							</td>
							</tr>
							
							<%next
							
							set SL_optcodeNONSkue=nothing 
							%>
							<tr><td>&nbsp;</td></tr>
							<tr><td class="plaintextbold">Price: Starting at  <%=formatcurrency(StockAttrib_MinPrice)%></td></tr>
							<%end if  'if has attribs%>
							
							
							
							
							<% if LOSTOCK.inetcustom= true or LOSTOCK.giftcert= true  then %>
							<tr><td><img alt="" src="images/clear.gif" width="1" height="15" border="0"></td></tr>							
								<%if LOSTOCK.giftcert= true then %>
								<tr><td class="THHeader">&nbsp;Please enter the following information</td></tr>
								<tr><td class="plaintextbold">Recipient's Name:</td></tr>
								<tr><td><input class="plaintext" type="text" name="Recipientname" size="30" maxlength="40"></td></tr>
								<tr><td><img alt="" src="images/clear.gif" width="1" height="15" border="0"></td></tr>
								<tr><td class="plaintextbold">Notation:</td></tr>
								<tr><td><textarea name="giftcertnotation" cols="30" rows="2" value></textarea></td></tr>
								<tr><td><img alt="" src="images/clear.gif" width="1" height="15" border="0"></td></tr>
								

							
								<%else%>
									<tr><td class="THHeader"><%=trim(LOSTOCK.inetcprmpt)%></td></tr>
									<tr><td><textarea name="txtcustominfo" cols="30" rows="2" value></textarea></td></tr>
								<%end if%>							
							<%end if%>
							
							<tr><td><img alt="" src="images/clear.gif" width="1" height="5" border="0">
							<%if has_stock_attribs=true then %>
							    <input type="hidden" name="maxoption" id="MaxAttriboption" value="<%=maxoption+1%>">
							    <input type="hidden" name="maxNONSkuOption" id="maxNONSkuOption" value="<%=maxTextoption+1%>">
							<%else %>
							    <input type="hidden" name="maxoption" id="MaxAttriboption" value="0">
							    <input type="hidden" name="maxNONSkuOption" id="maxNONSkuOption" value="0">
							<%end if %>
							
							</td></tr>
							<%if LOSTOCK.discont= true and LOSTOCK.units=0  then %>
								<tr><td class="plaintextbold" valign="bottom">
									This item is no longer available
									<br><br>
									<%if Has_Subs_ForDiscont=true then %>									
									<a href="itemadd.asp?ADDITEM=<%=current_stocknumber%>">Check for Subtitute items</a>
									<%end if%>
								</td></tr>
							<%else%>
							<%if LOSTOCK.giftcert= true then %>
							<input type="hidden" class="plaintext" name="txtquanto" value="1" size="4" MAXLENGTH="5" align="middle">
							<input type="hidden" class="plaintext" name="is_giftcert" value="1">
							<%else%>
								<tr><td class="plaintextbold" valign="bottom">Quantity&nbsp;<input type="text" class="plaintext" name="txtquanto" value="1" size="4" MAXLENGTH="5" align="middle">
								<input type="hidden" class="plaintext" name="is_giftcert" value="0">
								</td></tr>
							<%end if%>
							<tr><td><img alt="" src="images/clear.gif" width="1" height="10" border="0"></td></tr>
							<tr><td><input type="image" value="cart" onClick="displaythis(this)" src="images/btn-buynow.gif" style="border:0;" align="middle">							
							<%'if WANT_WISHLIST = 1 and session("registeredshopper")= "YES" then 
							  if WANT_WISHLIST = 1 and  LOSTOCK.giftcert= false  then
							%>					
			                  <br>
							  <input type="image" value="wishlist" onClick="displaythis(this)" src="images/btn_Add_Wishlist.gif" style="border:0;"> 
						   <%end if%>
						   <%end if%>
						  
							</td></tr>
							</table>
						</td>
					</tr>
					</table>
					
					<script type="text/javascript" language="javascript">
					 function AddtoBookMark() 
					 {
					var title = "<%=althomepage%>-<%=bookmarktitle%>";
					//var url = this.location;
					var url = '<%=insecureurl%>prodinfo.asp?number=<%=current_stocknumber%>';
					
					if (window.sidebar) { // Mozilla Firefox Bookmark
						window.sidebar.addPanel(title, url,"");
						} else if( window.external ) { // IE Favorite
							window.external.AddFavorite( url, title); }
						else if(window.opera && window.print) 
							{ // Opera Hotlist
							return true; }		
					}
                    function openWindow() 
                    {  
                        pagename = 'http://mail.mailordercentral.com/sitelink700/default.asp?item_url=<%=insecureurl%>prodinfo.asp?number=<%=cstr(current_stocknumber)%>&desc=<%=trim(bookmarktitle)%>'                        
                        popupWin = window.open(pagename, '', 'scrollbars,resizable,width=550,height=450')
                    }
					//-->
					</script>
					<br>
					<a class="allpage" href="javascript:AddtoBookMark();">Bookmark This Page</a>
					<br>
					<a class="allpage" href="javascript:openWindow();">Refer this page to a friend</a>
					
				</td>
              
	</tr>	
	</table>
	</form>
	
	<%
	    useadv1 = false
	    useadv2 = false
	    useadv3 = false
	    useadv4 = false
	    
	    if len(trim(session("SL_Advanced1"))) > 0 and len(trim(SLAdvanced1Val)) > 0 then
	        useadv1 = true
	    end if
	
	    if len(trim(session("SL_Advanced2"))) > 0 and len(trim(SLAdvanced2Val)) > 0 then
	        useadv2 = true
	    end if
	    if len(trim(session("SL_Advanced3"))) > 0 and len(trim(SLAdvanced3Val)) > 0 then
	        useadv3 = true
	    end if	
	    if len(trim(session("SL_Advanced4"))) > 0 and len(trim(SLAdvanced4Val)) > 0 then
	        useadv4 = true
	    end if	
	    
	
	 %>
	 
	 <%if useadv1=true or useadv2=true or useadv3=true or useadv4=true then %>
	    <table width="98%">
	        <tr>
	            <%if useadv1=true then %>
	                <td class="plaintext"><br><b><%=session("SL_Advanced1")%></b><a class="allpage" href="SetAdvancedSearch.asp?search=1&amp;what=<%=server.urlencode(SLAdvanced1Val)%>"><%=SLAdvanced1Val%></a></td>
	            <%end if%>
	            <%if useadv2=true then %>
	                <td class="plaintext"><br><b><%=session("SL_Advanced2")%></b><a class="allpage" href="SetAdvancedSearch.asp?search=2&amp;what=<%=server.urlencode(SLAdvanced1Va2)%>"><%=SLAdvanced2Val%></a></td>
	            <%end if%>
	            <%if useadv3=true then %>
	                <td class="plaintext"><br><b><%=session("SL_Advanced3")%></b><a class="allpage" href="SetAdvancedSearch.asp?search=3&amp;what=<%=server.urlencode(SLAdvanced1Va3)%>"><%=SLAdvanced3Val%></a></td>
	            <%end if%>
	            <%if useadv4=true then %>
	                <td class="plaintext"><br><b><%=session("SL_Advanced4")%></b><a class="allpage" href="SetAdvancedSearch.asp?search=4&amp;what=<%=server.urlencode(SLAdvanced1Va4)%>"><%=SLAdvanced4Val%></a></td>
	            <%end if%>
	        
	        </tr>
		</table>
	 <%end if %>
	
	 
	 <%  if len(trim(LOSTOCK.inetfdesc)) > 0 then %>
	<table width="98%"  border="0" cellpadding="3" cellspacing="0">
			<tr><td class="THHeader">&nbsp;Detailed Description</td></tr>
			<tr><td class="plaintext" style="text-align:justify;">			           	           
						<%=LOSTOCK.inetfdesc%>
						</td>
					</tr>
			</table>
	<%end if%>
	
	
		

	
	</div>
<!-- end sl_code here -->
	<br><br><br><br>
	</td>
	<%
		objDoc.loadxml(SL_CrossSellXmlStream)
		
		set SL_SellTool = objDoc.selectNodes("//seltool") 
		if SL_SellTool.length > 0 then
	%>
	<td width="150" valign="top" class="pagenavbg">

	<table width="100%" cellpadding="3" cellspacing="0">
			<tr><td align="center"><h3>You may also like:</h3> </td></tr>			

		  <% 

			rowcount=0   
			CSPROD_PER_LINE = 1			    					
			for x=0 to SL_SellTool.length-1
				SLsellNumber = SL_SellTool.item(x).selectSingleNode("sellwhatsku").text
				SLsellPrice  = SL_SellTool.item(x).selectSingleNode("price1").text
				SLsellTitle  = SL_SellTool.item(x).selectSingleNode("inetsdesc").text
				SLsellThumb  = SL_SellTool.item(x).selectSingleNode("inetthumb").text
				SLsellFull   = SL_SellTool.item(x).selectSingleNode("inetimage").text
				
				if WANT_REWRITE = 1 then
					 SL_urltitle = SLsellTitle
					 SL_urltitle = url_cleanse(SL_urltitle)
					 SLURLCodeNumber = server.URLEncode(trim(SLsellNumber))
					 prodlink = SL_urltitle + "/productinfo/" + SLURLCodeNumber 
				else 
					 prodlink = "prodinfo.asp?number=" + cstr(SLsellNumber)
				end if
				
						

			if rowcount=CSPROD_PER_LINE then
			rowcount=0
			%>
			<tr><td></td></tr>		     					
			<%end if%>
			
			<%if rowcount=0 then %>
		        <tr>
		    <%end if %>
		  
		   <td valign="top" width="<%=(100/CSPROD_PER_LINE)%>%" class="cross-sell-bg">				
		   <table  width="100%" border="0" cellspacing="0" cellpadding="0" class="table-layout-fixed">
			<tr>      
									
				 <% rowcount=rowcount+1
					 if SLsellThumb <>"" then
						StrFileName = "images/"+cstr(SLsellThumb)
					else
						StrFileName = "images/"+cstr(SLsellFull)
					end if
									 
					 found = false 
					 StrPhysicalPath = Server.MapPath(StrFileName)
					 set objFileName = CreateObject("Scripting.FileSystemObject")	
					 if objFileName.FileExists(StrPhysicalPath) then
						imagename=StrFileName
					else
						imagename="images/noimage.gif"
					end if 
					set objFileName = nothing
					
					%>
				   
					<td align="center"><div class="prodthumb"><div class="prodthumbcell"><a href="<%=prodlink%>"><img SRC="<%=imagename%>" alt="<%=SLsellTitle%>" title="<%=SLsellTitle%>" class="prodlistimg" <% if PROD_IMAGE_WIDTH > 0 and PROD_IMAGE_WIDTH <= 125 then  response.write(" width="""& PROD_IMAGE_WIDTH&"""") end if %> <%if PROD_IMAGE_HEIGHT > 0 then response.write(" height="""& PROD_IMAGE_HEIGHT&"""") end if %> border="0"></a></div></div></td>		                         
					</tr>
					<tr><td align="center">
					<a class="producttitlelink" href="<%=prodlink%>"><%=SLsellTitle%></a>
					</td></tr>
					<tr><td align="center" class="ProductPrice">
					<%=formatcurrency(SLsellPrice)%>
					</td></tr>
					<tr><td>&nbsp;</td></tr>
		</table>
		</td>											
		<%next%>
		<% diff = CSPROD_PER_LINE - rowcount 
			if diff > 0 then
				for y=1 to diff 
				%>
				<td>&nbsp;</td>
				<%next%>
		<%end if%>
		</tr>
				  
	</table>
	</td>
	<%end if%>
	
</tr>

</table>
<% 
	SET LOSTOCK = nothing
	set SL_sbcl = nothing
	set SL_gsp =  nothing
	set SL_SellTool=nothing
	set SL_ProdInfoDetails=nothing
%>

    </div> <!-- Closes main  -->
    <div id="footer" class="footerbgcolor">
    <!--#INCLUDE FILE = "include/bottomlinks.asp" -->
    <!--#INCLUDE FILE = "googletracking.asp" -->
    <!--#INCLUDE FILE = "RemoveXmlObject.asp" -->
    <!--#INCLUDE FILE = "text/footer.asp" -->
    </div>
</div> <!-- Closes container  -->


</body>
</html>