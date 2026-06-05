個人用のneovimの設定管理をしているよ

# 言語設定したいときやること

lang配下のファイルたちを編集する。  

- lsp.lua  
lsp設定追加する。  
設定項目ない場合もserver_optsに対象lsp名のプロパティ追加しないとenable()が実行されないので注意。  

- format.lua  
フォーマッタ設定する。  

- highlight.lua  
treesitterの言語パーサインストールしてなかったらする  
filetypeのautocmdに対象ファイルタイプ追加する。  
  
それ以外にも追加設定必要な場合は言語個別でファイルを作って設定する 。
例: rust(rustaceanivm), typescript(typescript-tools)  
