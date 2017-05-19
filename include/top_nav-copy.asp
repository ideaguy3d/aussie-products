<%

if session("returnvisitor")=false then
session("returnvisitor")=true
'session("restoreoldorder")=false
'session("restoreoldordernumber")=0
cookiename=cstr(ShortStoreName)+"order"
cookieval = (request.COOKIES(cookiename)("ordernumber"))
newcookieval = replace(cookieval," ","")
if isnumeric(newcookieval)= true then
SL_restoreoldorder = sitelink.READCOOKIE("order",cstr(cookieval))
if len(trim(SL_restoreoldorder)) > 0 then
if isnumeric(SL_restoreoldorder) = true then
'session("ordernumber") = cstr(SL_restoreoldorder)

xmlstring = sitelink.getbasketinfo(session("shopperid"),cstr(SL_restoreoldorder),"pricechang",false,false)
objDoc.loadxml(xmlstring)
set SL_Basket = objDoc.selectNodes("//gbi[certid=0]")

for x=0 to SL_Basket.length-1
SL_Number = SL_Basket.item(x).selectSingleNode("number2").text
SL_Variant= SL_Basket.item(x).selectSingleNode("variant").text
SL_BasketQty          = SL_Basket.item(x).selectSingleNode("quanto").text
SL_Basket_custominfo =SL_Basket.item(x).selectSingleNode("custominfo").text


SL_Basket_PriceChange =SL_Basket.item(x).selectSingleNode("pricechang").text
SL_Basket_Discount =SL_Basket.item(x).selectSingleNode("discount").text
SL_Basket_FullItem =SL_Basket.item(x).selectSingleNode("item").text
SL_Basket_UnitPrice =SL_Basket.item(x).selectSingleNode("it_unlist").text
SL_Basket_VatInc =SL_Basket.item(x).selectSingleNode("vatincl").text
SL_Basket_VatList =SL_Basket.item(x).selectSingleNode("vatlist").text

if SL_Basket_PriceChange="false" then
CALL sitelink.ITEMADD(cstr(SL_Number),cstr(SL_BasketQty),cstr(SL_Variant),session("shopperid"),session("ordernumber"),cstr(SL_Basket_custominfo),cint(0),cint(0))
else
if SL_Basket_VatInc="true" then
SL_Basket_UnitPrice = SL_Basket_VatList
end if
call sitelink.dydasuppadd(cstr(""),cstr(SL_Basket_FullItem),cstr(SL_BasketQty),cdbl(SL_Basket_UnitPrice),session("shopperid"),session("ordernumber"),true,cstr(SL_Basket_Discount),cstr(SL_Basket_custominfo))
end if
next

set SL_Basket = nothing

call SITELINK.quantitypricing(session("shopperid"),session("ordernumber"))

session("SL_BasketCount") = sitelink.GetData_Basket(cstr("BASKETCOUNT"),session("ordernumber"),session("SL_VatInc"))
session("SL_BasketSubTotal") = sitelink.GetData_Basket(cstr("BASKETSUBTOTAL"),session("ordernumber"),session("SL_VatInc"))
end if
end if
end if
end if

%>


<!-- START: SiteLink generated horizontal navigation -->
<div id="header" class="topnav1bgcolor">
	<!-- aussie logo area -->
	<div class="divlogo">
		<div class="logo-wrap">
			<div class="logo-img">
				<a href="<%=insecureurl%>" title="<%=althomepage%>">
					<%if COMPANY_LOGO_IMG<>"" then %>
					<img alt="<%=althomepage%>" src="images/<%=COMPANY_LOGO_IMG%>" border="0">
					<%else %>
					<img alt="<%=althomepage%>" src="images/clear.gif" width="1" height="1" border="0">
					<%end if %>
				</a>
			</div>
		</div>
	</div>

	<div id="j-top-right-nav" class="container-sm-inline">
    		<!-- shopping cart, basket, items row -->
    		<ul class="role-block grid-parent ul-base">
    			<li class="role-each-inline-30 grid-child">
    				<h4>
    					<a title="Shopping Cart" href="basket.asp">
    					    Cart  &nbsp; <i class="fa fa-shopping-cart"></i>
    					</a>
    				</h4>
    			</li>
    			<li class="TopNav1Text role-each-inline-30 grid-child">
    			    <h4>
    			        <%=session("SL_BasketCount")%>&nbsp;Items
    			        <%=formatcurrency(session("SL_BasketSubTotal"))%>
                    </h4>
                </li>
                <!-- Login / Logout button -->
    			<li class="TopNav1Text role-each-inline-30 grid-child">
    			    <% if session("registeredshopper")="NO" then %>
                        <a href="<%=secureurl%>login.asp" title="Login" class="btn btn-lg btn-default j-login-btn">Login</a>
                    <% else %> Hello, <%= session("firstname") %>
                        <a href="<%=secureurl%>logout.asp" title="Logout" class="btn btn-lg btn-default j-login-btn">Logout</a>
                    <%end if%>
    				<!--<button href="#" class="btn btn-lg btn-default j-login-btn">Login</button>-->
    			</li>
    		</ul>
            <br>
    		<!-- search form row -->
    		<form method="POST" id="searchprodform" action="searchprods.asp">
    			<input name="ProductSearchBy" value="2" type="hidden">

    			<!-- search form input -->
    			<input class="j-search-form" type="text" size="18" maxlength="256" name="txtsearch"
    			       value="Product Search" onfocus="if (this.value=='Product Search') this.value='';"
    			       onblur="if (this.value=='') this.value='Product Search';">

    			<button id="j-search-btn" type="submit" class="btn btn-warning btn-go">Search</button>
    		</form>
    	</div>
</div>
<!-- END: SiteLink generated horizontal navigation -->

<!-- START: top horizontal navigation -->
<nav id="j-nav1" class="navbar navbar-default">
	<div class="container-fluid">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse"
			        data-target="#j-top-nav-1st" aria-expanded="false">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="http://www.aussieproducts.com">
				<img alt="Brand" src="images/kangaroo.png" height="40px">
			 </a>
		</div>

		<!-- Bootstrap nav links, forms, and other content for toggling -->
		<div id="j-top-nav-1st" class="collapse navbar-collapse">
			<!-- website page links: -->
			<ul class="nav navbar-nav navbar-left j-pad-top-12">
				<li><a href="<%=insecureurl%>" title="<%=ALT_HOME_TXT%>">HOME</a></li>
				<%if DISP_ABOUT_PAGE = true then %>
				<li><a href="<%=insecureurl%>Aboutus.asp" title="<%=ALT_ABOUT_TXT%>">ABOUT US</a></li>
				<% end if %>
				<%if DISP_HELP_PAGE = true then %>
				<li><a href="<%=insecureurl%>help.asp" title="<%=ALT_HELP_TXT%>">SHIPPING</a></li>
				<% end if %>
				<%if DISP_CONTACT_PAGE = true then %>
				<li><a href="<%=insecureurl%>contactus.asp" title="<%=ALT_CONTACT_TXT%>">CONTACT US</a></li>
				<% end if %>

				<li><a href="<%=insecureurl%>basket.asp">VIEW CART</a></li>
			</ul>
			<!-- shopping cart nav:
			<ul class="nav navbar-nav">
				<li>
					<a title="Shopping Cart" href="basket.asp">Shopping Cart</a>
				</li>
				<li>
					 <i class="fa fa-shopping-cart fa-2x j-cart"></i>
				</li>
				<li>
					<a href="basket.asp"><=session("SL_BasketCount")%>&nbsp;Items</a>
				</li>
				<li>
					<a href="basket.asp"><=formatcurrency(session("SL_BasketSubTotal"))%></a>
				</li>
			</ul>
			-->

			<ul class="nav navbar-nav navbar-right">
			    <li><a href="https://www.facebook.com/aussieproducts#"><img src="http://www.niftybuttons.com/webicons2/facebook.png" alt="facebook"></a></li>
			    <li><a href="https://twitter.com/aussieproducts"><img src="http://www.niftybuttons.com/webicons2/twitter.png" alt="twitter"></a></li>
			    <li><a href="http://www.reddit.com/user/AussieProducts/"><img src="http://www.niftybuttons.com/webicons2/reddit.png" alt="reddit"></a></li>
			    <li><a href="http://pinterest.com/aussieproducts/"><img src="http://i.imgur.com/sxwB0TO.png" alt="pinterest"></a></li>
			    <li><a href="http://pinterest.com/aussieproducts/"><img src="http://www.niftybuttons.com/webicons2/stumbleupon.png" alt="stumble upon"></a></li>
            </ul>
		</div>

		<!-- social link buttons -->



	</div>
</nav>
<!-- END: top horizontal navigation -->