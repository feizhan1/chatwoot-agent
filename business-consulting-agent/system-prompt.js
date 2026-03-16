{{ 
  (() => {
    let template = $('env').first().json.prompt['business-consulting-agent']['system-prompt'];
    const { is_ai_suggest, out_template } = $('Code in JavaScript13').first().json || {};
    const dataMap = {};
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