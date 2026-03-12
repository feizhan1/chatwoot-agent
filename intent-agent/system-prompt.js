{{ 
  (() => {
    let template = $('env').first().json.prompt['intent-agent']['system-prompt'];
    const dataMap = {
      '{final_memory_context}': $('Code in JavaScript10').item.json.final_memory_context,
  };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}