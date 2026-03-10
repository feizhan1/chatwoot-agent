{{ 
  (() => {
    let template = $('env').first().json.prompt['product-agent-sop-executor']['user-prompt'];
    const now = new Date().toISOString();
    const { image_data, need_image_agent } = $('Code in JavaScript1').first().json || {};
    let ask = $('Code in JavaScript1').first().json.ask;
    if(need_image_agent) {
      ask = $('image-qus').first().json.ask || "hello"
    }
    const dataMap = {
      '{channel}': $('Code in JavaScript13').first().json.channel,
      '{target_language}': $('Code in JavaScript13').first().json.target_language,
      '{language_code}': $('Code in JavaScript13').first().json.language_code,
      '{login_status}': $('Code in JavaScript13').first().json.login_status,
      '{user_profile}': $('Code in JavaScript13').first().json.user_profile || '无',
      '{active_context}': $('Code in JavaScript13').first().json.active_context || '无',
      '{recent_dialogue}': $('Code in JavaScript13').first().json.recent_dialogue || '无',
      '{user_query}': ask,
      '{image_data}': image_data,
      '{current_system_time}': now,
      '{sale_name}': $('Code in JavaScript13').first().json.sale_name || '无',
      '{sale_email}': $('Code in JavaScript13').first().json.sale_email || '无',
  };
    for (const [placeholder, value] of Object.entries(dataMap)) {
      const safeValue = value ? value.toString() : ''; 
      template = template.replaceAll(placeholder, safeValue);
    }
    return template;
  })()
}}