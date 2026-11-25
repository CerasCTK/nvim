local M = {}

M.open = function()
    local source_bufnr = vim.api.nvim_get_current_buf()
    local source_winid = vim.api.nvim_get_current_win()

    local is_closed = require("undotree").open({ title = "UndoTree" })
    if is_closed then return end

    local tree_bufnr = vim.api.nvim_get_current_buf()

    vim.b[tree_bufnr].ceras_undotree_source = source_bufnr
    vim.b[tree_bufnr].ceras_undotree_source_win = source_winid
end

M.cancel = function()
    local tree_bufnr = vim.api.nvim_get_current_buf()
    local tree_winid = vim.api.nvim_get_current_win()

    local source_bufnr = vim.b[tree_bufnr].ceras_undotree_source

    if not source_bufnr or not vim.api.nvim_buf_is_loaded(source_bufnr) then
        vim.notify("UndoTree source buffer is unavailable", vim.log.levels.WARN, { title = "UndoTree" })
        return
    end

    local is_ok, err = pcall(vim.api.nvim_buf_call, source_bufnr, function()
        local undo_state = vim.fn.undotree()

        if undo_state.seq_cur ~= undo_state.seq_last then
            vim.cmd.undo({ args = { tostring(undo_state.seq_last) }, mods = { silent = true } })
        end
    end)

    if not is_ok then
        vim.notify(tostring(err), vim.log.levels.ERROR, { title = "UndoTree" })
        return
    end

    if vim.api.nvim_win_is_valid(tree_winid) then
        vim.api.nvim_win_close(tree_winid, false)
    end
end

M.confirm = function()
    local tree_bufnr = vim.api.nvim_get_current_buf()
    local tree_winid = vim.api.nvim_get_current_win()

    local source_bufnr = vim.b[tree_bufnr].ceras_undotree_source
    local source_winid = vim.b[tree_bufnr].ceras_undotree_source_win

    if not source_winid or not vim.api.nvim_win_is_valid(source_winid) then
        vim.notify("UndoTree source window is unavailable", vim.log.levels.WARN, { title = "UndoTree" })
        return
    end

    if vim.api.nvim_win_get_buf(source_winid) ~= source_bufnr then
        vim.notify("UndoTree source window has changed buffers", vim.log.levels.WARN, { title = "UndoTree" })
        return
    end

    vim.api.nvim_win_close(tree_winid, false)

    vim.api.nvim_set_current_win(source_winid)
    vim.cmd("normal! zz")
end

return M
