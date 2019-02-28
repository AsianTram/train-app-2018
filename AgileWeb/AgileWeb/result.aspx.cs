using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace AgileWeb
{
    public partial class result : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           if(Request.Form["day"]=="-1" | Request.Form["month"]=="-1" | Request.Form["hour"]=="-1" | Request.Form["minute"]=="-1" | Request.Form["duration"]==null)
            {
                // not work yet
                Response.Write(" <div class=\"alert\">< span class=\"closebtn\" onclick=\"this.parentElement.style.display='none';\">&times;</span>You have not give enough information.</div> ");
                //Response.Write("You have not give enough information");
                Response.Redirect("Search.aspx");
            }
        }
        public string twodigits(int a)
        {
            if (a < 10)
            {
                return "0" + a.ToString();
            }
            else
                return a.ToString();
        }
        
    }
}