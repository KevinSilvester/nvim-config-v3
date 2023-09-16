use std::{collections::VecDeque, path::Path, println, process::Stdio, sync::Mutex};

use ansi_term::Colour;
use strip_ansi_escapes::strip;
use tokio::process::Command;
use tokio_process_stream::{Item, ProcessLineStream};
use tokio_stream::StreamExt;

use crate::renderer::Renderer;

pub fn check_command_exists(command: &str) -> Result<(), std::io::Error> {
    match std::process::Command::new(command)
        .stdout(Stdio::null())
        .spawn()
    {
        Ok(_) => Ok(()),
        Err(e) => {
            if let std::io::ErrorKind::NotFound = e.kind() {
                c_println!(red, "ERROR: `{}` not found", command);
                Err(e)
            } else {
                Ok(())
            }
        }
    }
}

fn clean_string(s: &str) -> String {
    let bytes = s.as_bytes();
    strip(bytes);
    String::from_utf8(Vec::from(bytes)).unwrap()
}

pub async fn run_command(
    name: &str,
    args: &Vec<&str>,
    cwd: Option<&Path>,
) -> Result<(), Box<dyn std::error::Error>> {
    let mut command = Command::new(name);
    command.args(args);
    if let Some(cwd) = cwd {
        command.current_dir(cwd);
    }

    let turquoise = Colour::RGB(66, 242, 245);
    let blue = Colour::RGB(2, 149, 235);
    let red = Colour::RGB(235, 66, 66);
    let green = Colour::RGB(57, 219, 57);

    let max_lines: usize = 20;

    let mut renderer = Renderer::new();
    let mut out_queue: VecDeque<String> = VecDeque::with_capacity(max_lines);
    let mut is_finished = false;
    let mut failed = false;

    println!(
        "\n{} {} {} {}",
        turquoise.paint("=>"),
        name,
        args.join(" "),
        blue.paint("(running...)")
    );
    let mut procstream = ProcessLineStream::try_from(command)?;

    for _ in 0..max_lines {
        if let Some(item) = procstream.next().await {
            match item {
                Item::Done(status) => {
                    is_finished = true;
                    failed = !status.unwrap().success();
                    break;
                }
                Item::Stdout(out) => {
                    out_queue.push_back(format!("   {} {}", blue.paint("=>"), clean_string(&out)));
                }
                Item::Stderr(err) => {
                    out_queue.push_back(format!("   {} {}", red.paint("=>"), clean_string(&err)));
                }
            }
            // renderer.render_queue(&out_queue)?;
        } else {
            is_finished = true;
            break;
        }
    }

    if !is_finished {
        while let Some(item) = procstream.next().await {
            out_queue.pop_front();
            match item {
                Item::Done(status) => {
                    failed = !status.unwrap().success();
                    break;
                }
                Item::Stdout(out) => {
                    out_queue.push_back(format!("   {} {}", blue.paint("=>"), clean_string(&out)));
                }
                Item::Stderr(err) => {
                    out_queue.push_back(format!("   {} {}", red.paint("=>"), clean_string(&err)));
                }
            }
            renderer.render_queue(&out_queue)?;
        }
    }

    renderer.clear_ouput()?;

    if failed {
        eprintln!(
            "{} {} {} {}",
            red.paint("=>"),
            name,
            args.join(" "),
            red.paint("(failed!)")
        );
        panic!("{} failed", name);
    } else {
        println!(
            "{} {} {} {}",
            turquoise.paint("=>"),
            name,
            args.join(" "),
            green.paint("(complete!)")
        );
    }

    Ok(())
}

pub async fn build_ts_parsers(ts_parers_path: &Path) -> Result<(), Box<dyn std::error::Error>> {
    check_command_exists("pnpm")?;
    let mut has_node_modules = false;

    if ts_parers_path.join("node_modules").is_dir() {
        has_node_modules = true;
    }

    if !has_node_modules {
        c_println!(blue, "Installing ts-parsers dependencies...");
        run_command(
            "pnpm",
            &vec![
                "install",
                "-C",
                ts_parers_path.to_str().unwrap(),
                "--frozen-lockfile",
            ],
            None,
        )
        .await?;
    }

    c_println!(blue, "Building ts-parsers...");
    run_command(
        "pnpm",
        &vec!["run", "-C", ts_parers_path.to_str().unwrap(), "build"],
        None,
    )
    .await?;

    Ok(())
}
