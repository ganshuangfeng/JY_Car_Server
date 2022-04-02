package com.huawei;

//import org.apache.commons.codec.binary.Base64;

import java.util.Base64;

import java.io.IOException;

import java.io.UnsupportedEncodingException;

import java.net.URLEncoder;

import java.nio.charset.Charset;

import java.security.KeyFactory;

import java.security.PrivateKey;
       
import java.security.PublicKey;

import java.security.Signature;

import java.security.cert.CertificateException;

import java.security.cert.X509Certificate;

import java.security.spec.PKCS8EncodedKeySpec;

import java.security.spec.X509EncodedKeySpec;

import java.util.ArrayList;

import java.util.HashMap;

import java.util.List;

import java.util.Map;

import java.util.TreeMap;

 

public class huawei_sign {
 public huawei_sign(){
  super();
 }

 public static int add(int a,int b) {
  System.out.println("11111111111111111111111111111111111111111111111111111111");
  return a+b;
 }

 public boolean judge(boolean bool) 
 {
    return !bool;
 }

  public static String sign(String content, String privateKey) 
  {
    // 测试
    //content = "fsdfsdfsdfs";
    //privateKey = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCN2oErzO0rJcFB8t0j3LIjBMmqH9WNJvvXtznamMERV1y39eG9Ex5eQXnL+q5suYMOouzb1r8rqAGDFJqU+1nmSJ6RGe0fwZI+HEXlTp7WQ7rM5fetJDwpfnQ10p4khtn9xXx7gOvk2symtm7rKc93Vybp3gpitzjW7nW2+732QdLgUufx+eOm0EFATYUAQXoOrcAdk01gxuk1X9Nbqj0P4yjmsCNjaYyewIpckcBBVtN5KKps2hl1pEW4oNf10llOEYxKA73DLNRv6GdFHpPVzKcPIrFDRxH30y0bnYaZIakOB247wNTTaPZghqBRb7c7Mc/hUi820FMhbA04H+ubAgMBAAECggEABQ3W8lePz6y9sPrVNDTlx+egw8X0lt3ftTTbA9XTcym4rPk+vLzUpSkSDNl2o3sMl1XouIBzOTv4KdJvG4XFEzZdJ/BTiYEdE8dwGhZuBFZPboN3Cp0y44uU2mIRrl17oNYLdF8IiJPfHMV9ODW6JZdeVJDLr+61QLsoSIe5oe9yidyWbePVwbIAIWNg7q3xMX9LN6A4C1B1rzAx7ruDJNNOx9muhlPSP0HAjha++NDt/9EEvsxQjnhTwdX+UubsjEi8lH8C1TkgzFJoKqfAExZMJHvt7DOCADObM4MrKw7ziSfo10cztH1m09MjaUgZHZo42lgXRsTmCF5D2AUMsQKBgQDtkHgxZCvumdYsUgKeea9cVJDmSCyKx5tak7Fn4p/VtYq09DqfoeIOMP+F+gq3+ITEJ0dMUOYyVTROX9WOeoyT4q94G8mRvGk7TJGETb4UtQeAI/r4n+g6v4W99Qfb1BmTpGkXPNq+jIDG2dBB5S7MTe9mn2rvr+5orRmkCfoMKQKBgQCY3Jz0xlkDrwukguc0zKRUYx4ypcWFlQ7xO5+bEBH7byB43QeCOFY0TmXuJW1e8ePXUt14AN23rY02zuY9bttD6qOn8cDE1VKPqPaSmKka8EUugeWQ74Uw7xvVpbjJHSpxttzxO6HlMaA6yz0V6E4/7XEQ8DsNOCUI52g0hhZyIwKBgQC7Uds0NuRdM3gpYlEmXJTlnNjUe7yDgXkCJssQOyYFASzqGlnPXXo97mzNW6fwAEnP0ZjqmC+rKHwiAHcH7aHDSk9Jyb9a5tGjLHDhfduPwF61r6lJOe2HxVTTv83+jHPOcylaZWWmMmuoYD9SdkA8YIeQx8suS+8VIsjBDAzaYQKBgQCLcNvAsdrrcFd3h23vjSnuTMh0PSH0nCeYSOJsafltWk7N0hqSYF/KsSVsWzns3U0Q0+dxG6Eld6yUraH7sk9UIguOHQrSwyHgKKpcyeOgzkLdjOLkFopyO/wxJU5uLyvTtZLQf6xMTbuzRkh/3nza9fcpE2tawLeP6r/1Acgh7wKBgBpPMy3n514ffxZ46h0DAmrye3wD/fPvE2cZOEE+Lbn3X8r01BC8/W5axGDt+1beDVNFphvE9m1fvntwN/2HZxqIIUHtEfjxTNZ7Oesskqn2OjpSzme03P3zLo0ARIxxNcAyjpc5tvOnkwZC1KcuuIP7HPyXFQLJb+AprlqEuvHH";
  
    try
    {
      //byte[] e = Base64.decodeBase64(privateKey);      
      byte[] e = Base64.getDecoder().decode(privateKey);
      
      //System.out.println(new String(e));

      byte[] data = content.getBytes();
      
      PKCS8EncodedKeySpec pkcs8KeySpec = new PKCS8EncodedKeySpec(e);

      KeyFactory keyFactory = KeyFactory.getInstance("RSA");

      PrivateKey privateK = keyFactory.generatePrivate(pkcs8KeySpec);

      Signature signature = Signature.getInstance("SHA256WithRSA");

      signature.initSign(privateK);

      signature.update(data);

      //String signs = Base64.encodeBase64String(signature.sign());
      String signs = Base64.getEncoder().encodeToString(signature.sign());

      //System.out.println(signs);

      return signs;
    }
    catch (Exception var)
    {
      System.out.println("SignUtil.sign error." + var);
      return "";
    }
  }

   
  public static final String SIGN_ALGORITHMS = "SHA1WithRSA"; 
  public static final String SIGN_ALGORITHMS256 = "SHA256WithRSA";

  public static boolean verify(String content, String sign, String publicKey, String signtype)
  {
    // 测试
    //publicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjdqBK8ztKyXBQfLdI9yyIwTJqh/VjSb717c52pjBEVdct/XhvRMeXkF5y/qubLmDDqLs29a/K6gBgxSalPtZ5kiekRntH8GSPhxF5U6e1kO6zOX3rSQ8KX50NdKeJIbZ/cV8e4Dr5NrMprZu6ynPd1cm6d4KYrc41u51tvu99kHS4FLn8fnjptBBQE2FAEF6Dq3AHZNNYMbpNV/TW6o9D+Mo5rAjY2mMnsCKXJHAQVbTeSiqbNoZdaRFuKDX9dJZThGMSgO9wyzUb+hnRR6T1cynDyKxQ0cR99MtG52GmSGpDgduO8DU02j2YIagUW+3OzHP4VIvNtBTIWwNOB/rmwIDAQAB";
   
    try
    {            
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");            

        byte[] encodedKey = Base64.getDecoder().decode(publicKey);            

        PublicKey pubKey = keyFactory.generatePublic(new X509EncodedKeySpec(encodedKey));            

        java.security.Signature signature = null;            

        if ("RSA256".equals(signtype)) 
        {
           signature = java.security.Signature.getInstance(SIGN_ALGORITHMS256);            
        } 
        else 
        {
           signature = java.security.Signature.getInstance(SIGN_ALGORITHMS);            
        }            

        signature.initVerify(pubKey);            

        signature.update(content.getBytes("utf-8"));            

        boolean bverify = signature.verify(Base64.getDecoder().decode(sign));      

        return bverify;    
    } 
    catch (Exception e) 
    {       
        e.printStackTrace();
    }            
    return false;
 }            
      
}