local M = {}

M.get_supported_language = function(bufnr, query_type)
    local is_non_file_buffer = vim.bo[bufnr].buftype ~= ""
    if is_non_file_buffer then return nil, "special_buffer" end

    local filetype = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(filetype)

    if not lang then return end

    local is_query_available, query = pcall(vim.treesitter.query.get, lang, query_type)
    if not is_query_available or not query then return end

    return lang
end

return M
