$netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

function DownloadFile($url, $pathToFile) {
  SetAllowUnsafeHeaderParsing20;
  $wc=(new-object System.Net.WebClient);
  $wc.Headers.Add('user-agent', 'ASP.NET WebClient');
  echo $url
  echo $pathToFile
  $wc.DownloadFile("$url", "$pathToFile");
}

function SetAllowUnsafeHeaderParsing20
{
  if($netAssembly)
  {
      $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
      $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

      $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

      if($instance)
      {
          $bindingFlags = "NonPublic","Instance"
          $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

          if($useUnsafeHeaderParsingField)
          {
            $useUnsafeHeaderParsingField.SetValue($instance, $true)
          }
      }
  }
}
