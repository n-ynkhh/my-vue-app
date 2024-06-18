            if "-asr-" in file and file.endswith(".csv"):
                # 新しいファイル名を設定
                new_file_name = f"{doc_id}_{os.path.basename(file)}"
                # 保存パスを設定
                save_path = os.path.join(save_dir, new_file_name)
                
                # ファイルを保存
                with z.open(file) as source, open(save_path, "wb") as target:
                    target.write(source.read())
                print(f"Extracted {file} to {save_path}")
