<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="AgileWeb.Search" ValidateRequest="false" %>

<!DOCTYPE html>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Xml" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <meta charset="utf-8"/>
        <link rel="stylesheet" href="style.css"/>
        <link href="https://fonts.googleapis.com/css?family=Poiret+One" rel="stylesheet"/>
        <title>Train Data</title>
</head>
<body>
    <form id="form1" runat="server" action="result.aspx">
        <header><img src="train.png"/>Train Data</header>
    <div id="wrapper">
        <div class="station"><img class="img3" src="station.png" style="height: 110px; margin-left: 580px; margin-top: -30px;"/>Choose a railway station
            <select class="select1" name="Place">
				<!--
                <option value="Helsinki"></option>
                <option value="Helsinki">Helsinki</option>
                <option value="Jyväskylä">Jyväskylä</option>
                <option value="Kouvola">Kouvola</option>
                <option value="Lahti">Lahti</option>
                <option value="Riihimäki">Riihimäki</option>
                <option value="Tampere">Tampere</option>
                <option value="Turku">Turku</option>
				-->
				<%
					StringWriter writer = new StringWriter();
					WebRequest webRequest = WebRequest.Create(@"https://rata.digitraffic.fi/api/v1/live-trains/station/HKI?minutes_before_departure=15&minutes_after_departure=15&minutes_before_arrival=15&minutes_after_arrival=15");
					WebResponse webResponse = webRequest.GetResponse();
					Stream datastream = webResponse.GetResponseStream();
					StreamReader streamReader = new StreamReader(datastream);
					string responsestring = streamReader.ReadToEnd();
					string[] responsestringarray = responsestring.Split('{');
					List<string> available_station = new List<string>();
					for(int i=0; i< responsestringarray.Length;i++)
					{
						if(responsestringarray[i].Contains("stationShortCode")&& responsestringarray[i].Contains("trainStopping\":true"))
						{
							int index = responsestringarray[i].IndexOf("stationShortCode") + 19;
							int space = responsestringarray[i].IndexOf(",", index) - 1 - index;
							string ava_sta = responsestringarray[i].Substring(index, space);
							available_station.Add(ava_sta);
						}
					}
					StringWriter stringWriter = new StringWriter();
					WebRequest request = WebRequest.Create(@"https://rata.digitraffic.fi/api/v1/metadata/stations");
					WebResponse response = request.GetResponse();
					Stream stream = response.GetResponseStream();
					StreamReader reader = new StreamReader(stream);
					string serverRespond = reader.ReadToEnd();
					string[] cutpart = serverRespond.Split('{');
					for (int i=1; i< cutpart.Length;i++)
					{
						int index1 = cutpart[i].IndexOf("stationName")+ 14;
						int take = cutpart[i].IndexOf("\",", index1)-index1;
						string stationName = cutpart[i].Substring(index1, take);
						int index2 = cutpart[i].IndexOf("stationShortCode")+ 19;
						int take2 = cutpart[i].IndexOf("\",", index2)-index2;
						string shortCode = cutpart[i].Substring(index2, take2);
						if (available_station.Contains(shortCode))
						{
							Response.Write("<option value=\""+shortCode +"\">"+stationName+"</option>");
						}
						
					}

				%>
            </select>
        </div>
        <div class="time"><img class="img2" src="clock1.png" style="height: 100px; margin-left: -140px; margin-top: -30px;">Choose time
            <select class="select2" name="minute">
                <option value="-1"></option>
                <%
                    for(int i = 0; i < 60; i ++)
                        {
                            Response.Write("<option value='"+i+ "'>"+i+ "</option> <br>");
                        }
                %>
            </select>
            <select class="select3" name="hour">
                <option value="-1"></option>
                <% 
                     for (int i = 0; i <24; i++)
                        {
                            Response.Write("<option value='"+i+"'>" +i + "</option><br>");
                        }
                %>
            </select>
			</div>
			<div class="time1">
				Duration <select class="select4" name="duration">
                <option value="0"></option>
                <% 
                     for (int i = 0; i <24; i++)
                        {
                            Response.Write("<option value='"+i+"'>" +i + "</option><br>");
                        }
                %>
					</select>
			</div>
			 <div class="date"><img class="img4" src="/dateima.png" style="height: 80px; margin-left: -123px; margin-top: -20px;"/>
				 <label><%Response.Write(DateTime.Today.Day.ToString()+"/"+DateTime.Today.Month.ToString()+"/"+DateTime.Today.Year.ToString()); %></label>
			 </div>
		<!--
            <div class="date"><img class="img4" src="/dateima.png" style="height: 80px; margin-left: -123px; margin-top: -20px;"/>Choose date
                <select class="select2" name="month">
                <option value="-1"></option>
                <%
					/*
                    for (int i = 0; i <= 12; i ++)
                            {
                                Response.Write("<option value='" + i+ "'>"+ i+ "</option>");
                            }
                %>
            </select>
            <select class="select3" name="day">
                <option value="-1"></option>
                <% 
                    for (int i = 1; i < 32; i++)
                            {
                                Response.Write("<option value='"+i+"'>" +i +"</option>");
                            }
							*/
                %>
  
            </select>
            </div>
		-->
		
                    <input type ="submit" value="Search" id="button" /> 
                
    </div>
    <footer>© 2018 All Rights Reserved. Use of this site constitutes acceptance of our Terms of Use and Privacy Policy.</footer>
    </form>
</body>
</html>
