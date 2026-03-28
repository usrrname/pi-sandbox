 Prompt Templates

 ~/.pi/agent/prompts/

 ```
   signal-bridge.md    - "You are building a Signal-PI bridge..."     
   code-review.md      - "Review code for bugs and security..."       
   quick-fix.md        - "Fix this bug concisely..."                  
 ```

 Settings

 ~/.pi/agent/settings.json

 ```json
   {                                                                  
     "defaultModel": "claude-sonnet-4-5",                             
     "compaction": {                                                  
       "enabled": true,                                               
       "reserveTokens": 16384,                                        
       "keepRecentTokens": 25000                                      
     }                                                                
   }                                                                  
 ```

## OWASP Top 10 for Gen AI - Applied to Pi + Signal Bridge

 ┌────┬────────────────┬────────────────────────┬───────────────────┐
 │ #  │ Risk           │ Pi Relevance           │ Mitigation        │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 1  │ Prompt         │ Malicious Signal       │ Sanitize input;   │
 │    │ Injection      │ messages could inject  │ limit tool        │
 │    │                │ commands               │ permissions       │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 2  │ Insecure       │ Bridge could expose pi │ Validate/filter   │
 │    │ Output         │ responses unfiltered   │ responses before  │
 │    │                │                        │ sending           │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 3  │ Training Data  │ N/A (pi doesn't train) │ -                 │
 │    │ Poisoning      │                        │                   │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 4  │ Model DoS      │ Unlimited Signal       │ Rate limiting,    │
 │    │                │ messages → token       │ message size caps │
 │    │                │ exhaustion             │                   │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 5  │ Supply Chain   │ Untrusted              │ Pin versions,     │
 │    │                │ extensions/packages    │ audit code before │
 │    │                │                        │ loading           │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 6  │ Sensitive Info │ Session data, API keys │ Encrypt sessions; │
 │    │                │ in logs                │ redact in output  │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 7  │ Insecure       │ Extensions run         │ Sandboxing;       │
 │    │ Plugins        │ arbitrary code         │ review extensions │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 8  │ Excessive      │ pi executes tools      │ Limit tool access │
 │    │ Agency         │ autonomously           │ per channel       │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 9  │ Overreliance   │ Auto-response without  │ Add approval step │
 │    │                │ human review           │ for destructive   │
 │    │                │                        │ actions           │
 ├────┼────────────────┼────────────────────────┼───────────────────┤
 │ 10 │ Model Theft    │ N/A (local inference)  │ -                 │
 └────┴────────────────┴────────────────────────┴───────────────────┘

  Key Fixes for Signal Bridge

 ```javascript
   // 1. Rate limiting                                                
   const rateLimit = new Map();                                       
   if (rateLimit.get(sender) > 10) return; // max 10 msgs/min         
                                                                      
   // 2. Input sanitization                                           
   const clean = message.replace(/[;|$|`]/g, "");                     
                                                                      
   // 3. Output filtering                                             
   if (response.includes(process.env.API_KEY)) response =             
 "[redacted]";                                                        
                                                                      
   // 4. Approval for dangerous actions                               
   if (command.includes("rm") || command.includes("sudo")) {          
     return "This action requires manual review";                     
   }                                                                  
 ```

  Key Fixes for Signal Bridge

 ```javascript
   // 1. Rate limiting                                                
   const rateLimit = new Map();                                       
   if (rateLimit.get(sender) > 10) return; // max 10 msgs/min         
                                                                      
   // 2. Input sanitization                                           
   const clean = message.replace(/[;|$|`]/g, "");                     
                                                                      
   // 3. Output filtering                                             
   if (response.includes(process.env.API_KEY)) response =             
 "[redacted]";                                                        
                                                                      
   // 4. Approval for dangerous actions                               
   if (command.includes("rm") || command.includes("sudo")) {          
     return "This action requires manual review";                     
   }                                                                  
 ```
