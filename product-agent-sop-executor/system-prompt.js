{{ 
  (() => {
    let template = $('env').first().json.prompt['product-agent-sop-executor']['system-prompt'];
    const dataMap = {
      '{SOP}': $json.executor_system_prompt,
      '{target_language}': $('Code in JavaScript13').first().json.target_language,
  };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}