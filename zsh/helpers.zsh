# ==============================================================================
# ヘルパー関数定義
# ==============================================================================
# ------------------------------------------------------------------------------
# プラグインインストール&ロード用関数
# ------------------------------------------------------------------------------
ZPLUGINDIR="${ZDOTDIR}/plugins"

_zplugin_load() {
    local plugin_path="${ZPLUGINDIR}/${2}"
    if [[ ! -d "$plugin_path" ]]; then
        mkdir -p "$ZPLUGINDIR"
        echo "Installing ${2}..."
        git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" ||
            {
                echo "ERRO: failed to install ${2}" >&2
                return 1
            }
    fi
    source "${plugin_path}/${2}.plugin.zsh"
}

# oh-my-zshのgitだけなど、プラグインの一部をインストール&ロードする
_zplugin_load_part() {
    local part_path=${3}
    local plugin_name=$(basename ${part_path})
    local plugin_path="${ZPLUGINDIR}/${plugin_name}"
    local remote_repo="https://github.com/${1}/${2}"

    # プラグインがインストールされていない場合はインストールする
    if [[ ! -d "$plugin_path" ]]; then
        mkdir -p "$ZPLUGINDIR"
        local tmp_path=$(mktemp -d /tmp/zsh_zplugin_load_part.XXXXXX)
        echo "Installing ${plugin_name}..."
        # 指定のディレクトリのみ取得
        git clone --filter=blob:none --sparse "$remote_repo" "$tmp_path" ||
            {
                echo "ERRO: failed to install ${remote_repo}" >&2
                rm -rf ${tmp_path}
                return 1
            }
        (cd "$tmp_path" && git sparse-checkout set "${part_path}")

        # 指定のディレクトリが取得できた場合はzshのプラグインディレクトリに配置
        # できなかったら終了
        if [[ -d "${tmp_path}/${part_path}" ]]; then
            cp -r "${tmp_path}/${part_path}" ${ZPLUGINDIR}/
            rm -rf ${tmp_path}
        else
            echo "ERRO: '${remote_repo}/${part_path}' is not exist" >&2
            rm -rf ${tmp_path}
            return 1
        fi
    fi
    source "${plugin_path}/${plugin_name}.plugin.zsh"
}

# ------------------------------------------------------------------------------
# プラグインアップデート用関数(手動で実行)
# ------------------------------------------------------------------------------
zplugin_update() {
    local dir
    for dir in "${ZPLUGINDIR}"/*/; do
        echo "Updating ${dir:t}..."
        git -C "$dit" pull --ff-only
    done
}
