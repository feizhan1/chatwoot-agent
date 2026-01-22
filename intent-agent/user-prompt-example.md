请使用以下分层信息来理解用户的请求。

<session_metadata>
    Channel: 
    Login Status: This user is not logged in.
    Target Language: English
    Language Code: en
</session_metadata>

<memory_bank>
    ### User Long-term Profile (Historical Data)
    - undefined

    ### Active Context (Current Session Summary)
    - User, a customer engaging with support, requests packing list and invoice for customs clearance.
- The user, a customer of TVCMALL, wants to learn more about dropshipping services offered by TVCMALL.
- User is requesting product images.
</memory_bank>

<recent_dialogue>
    ai: "\"My account\" provides high-resolution, watermark-free images. Images for ordered products can be downloaded directly. For unordered products, download permissions depend on customer level. Please log in to access these features. You may visit Thrive Perks for more details: https://www.tvcmall.com/reward"
human: Can I download the product image? For example: 6604028714A
ai: "Since you are not logged in, you cannot download product images directly.\n\n\"My account\" provides high-resolution, watermark-free images. Images for ordered products can be downloaded directly. For unordered products, download permissions depend on customer level.\n\nPlease log in to access these features. You may visit Thrive Perks for more details: https://www.tvcmall.com/reward"
human: What payment methods do you accept?
ai: "We accept the following payment methods:\n\n- PayPal \n- T/T (Bank Transfer/Wire Transfer) \n- Credit Cards \n\nThese options provide flexibility and security when completing your purchase. For more details, please visit: [Payment Methods](https://www.tvcmall.com/paymentsrefunds)."
human: Can you provide a packing list and invoice for customs clearance?
ai: "Yes, we can provide the packing list and invoice for customs clearance. Please contact your sales manager, and they will send you the requested documents as soon as possible to assist with the customs process."
human: Do you support dropshipping?
ai: "TVCMALL offers comprehensive dropshipping support designed to help you run your online store efficiently without holding inventory. Key features include:\n\n- API integration and data synchronization for streamlined operations.\n- Ability to launch products on third-party platforms.\n- No minimum order requirement for 95% of products, providing great flexibility.\n- Fast order fulfillment with typical lead times of 4-6 days.\n- Customization services (OEM/ODM) to personalize products with your branding or unique designs.\n- Sourcing assistance for hard-to-find items.\n- Dedicated one-on-one sales support and reliable customer care with responses within 2 hours.\n- A global network trusted by 1.5 million customers across 200+ countries.\n\nFor more detailed information, please visit the dropshipping page: [TVCMALL Dropshipping](https://www.tvcmall.com/dropshipping)."
human: Yes, I’d like to learn more about dropshipping.
ai: "TVCMALL offers comprehensive dropshipping solutions designed to help you run your online store efficiently without holding inventory. Key dropshipping features include:\n\n- **API integration** and data synchronization for streamlined operations.\n- The ability to **launch products** on third-party platforms directly.\n- **No minimum order requirement** on 95% of products, offering great flexibility.\n- **Fast order fulfillment** with typical lead times of 4-6 days for most products.\n- **Customization services (OEM/ODM)** to personalize products with your branding or unique designs, helping you stand out.\n- **Sourcing assistance** for hard-to-find items, saving you time and effort.\n- Dedicated **one-on-one sales support** to help you select products and support your business model.\n- Comprehensive **after-sales service** ensuring quick issue resolution and customer satisfaction.\n\nFor more detailed information, please visit the dropshipping page: \n[TVCMALL Dropshipping](https://www.tvcmall.com/dropshipping)."
human: What is your quality control process?
ai: "TVCMALL implements a high-level quality control process by thoroughly double-checking every product before shipping to ensure its quality. Detailed product descriptions and inspection services are also provided to support quality assurance. For a more comprehensive understanding of the quality control process, you can refer to the full Warranty Policy [here](https://www.tvcmall.com/return). \n\nIf you have any further questions about dropshipping or other services, feel free to ask!"
human: Can you provide a packing list and invoice for customs clearance?
ai: "Yes, we can provide the packing list and invoice for customs clearance. As a dropshipper, you can request these documents through your sales manager, who will send them to you as soon as possible to assist with the customs process.\n\nIf you have any further questions or need additional support with your dropshipping activities, feel free to ask!"
human: Can you provide a packing list and invoice for customs clearance?
ai: "Yes, we can provide the packing list and invoice for customs clearance. Please contact your sales manager, and they will send you the requested documents as soon as possible to assist with your customs process. If you have any further questions or need additional support with your dropshipping activities, feel free to ask!"
human: How long will it take to ship to my country?
ai: "Could you please specify which country you would like the shipment to be sent to? This will help us provide more accurate shipping time information."
human: China
</recent_dialogue>

<current_request>
    <user_query>
        China
    </user_query>
</current_request>

<instructions>
    1. **首先检查 <recent_dialogue>**：如果用户使用指代词（"那个订单"、"这个产品"、"它"）或省略主语，请从最近 1-2 轮对话中寻找被指代的实体。
    2. **分析 <user_query>**：结合对话历史，识别用户的真实意图。
    3. **查阅 <memory_bank>**：了解用户的长期偏好和当前会话的活跃主题。
    4. **严格遵循优先级**：安全检测 → 明确意图（含从上下文补全）→ 模糊意图 → 闲聊。
    5. **关键原则**：仅当 recent_dialogue 和 active_context 中**都没有**相关信息时，才归类为 `need_confirm_again`。
</instructions>