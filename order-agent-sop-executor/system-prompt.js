{{ 
  (() => {
    let template = $('env').first().json.prompt['order-agent-sop-executor']['system-prompt'];
    const { is_ai_suggest, out_template } = $('Code in JavaScript13').first().json || {};
    const dataMap = {
      '{SOP}': $json.executor_system_prompt,
    };
    if (!is_ai_suggest) {
      dataMap['{out_template}'] = out_template;
    };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}