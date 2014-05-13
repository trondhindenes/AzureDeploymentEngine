using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace AzureDeploymentEngine
{
    public class JsonFunctions
    {
        public AzureDeploymentEngine.Deployment ConvertToDeploymentFromJson(string JsonString)
        {
            AzureDeploymentEngine.Deployment ConvertedObject = JsonConvert.DeserializeObject<AzureDeploymentEngine.Deployment>(JsonString);
                return ConvertedObject;
        }
    }
}
