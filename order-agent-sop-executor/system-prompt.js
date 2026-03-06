{{ 
  (() => {
    let template = $('env').first().json.prompt['order-agent-sop-executor']['system-prompt'];
    const dataMap = {
      '{SOP}': $json.executor_system_prompt
  };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}