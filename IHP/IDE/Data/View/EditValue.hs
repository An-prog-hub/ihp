module IHP.IDE.Data.View.EditValue where

import IHP.ViewPrelude
import IHP.IDE.SchemaDesigner.Types
import IHP.IDE.ToolServer.Types
import IHP.IDE.ToolServer.Layout
import IHP.View.Modal
import IHP.IDE.SchemaDesigner.View.Layout
import IHP.IDE.ToolServer.Types
import IHP.IDE.Data.View.ShowDatabase
import IHP.IDE.Data.View.Layout
import Data.Maybe

data EditValueView = EditValueView
    { tableNames :: [Text]
    , tableName :: Text
    , rows :: [[DynamicField]]
    , targetName :: Text
    , targetId :: Text
    }

instance View EditValueView ViewContext where
    html EditValueView { .. } = [hsx|
        <div class="container pt-5">
            <div class="row no-gutters bg-white">
                {renderTableSelector tableNames tableName}
                <div class="col">
                    {renderRows}
                </div>
            </div>
            {customQuery}
        </div>
    |]
        where
            renderRows = [hsx|
                <table class="table table-sm table-hover table-striped data-rows-table">
                    {tableHead}
                    {tableBody}
                </table>
            |]

            tableHead = [hsx|<thead><tr>{forEach columnNames renderColumnHead}
                <td><a href={NewRowAction tableName} class="btn btn-primary btn-sm">Add</a></td>
            </tr></thead>|]
            renderColumnHead name = [hsx|<th>{name}</th>|]

            tableBody = [hsx|<tbody>{forEach rows renderRow}</tbody>|]
            renderRow fields = [hsx|<tr oncontextmenu={"showContextMenu('" <> contextMenuId <> "');"}>{forEach fields (renderField id fields)}
            </tr>
            <div class="custom-menu menu-for-column shadow backdrop-blur" id={contextMenuId}>
                <a href={EditRowAction tableName id}>Edit Row</a>
                <a href={DeleteEntryAction id tableName} class="js-delete">Delete Row</a>
                <div></div>
                <a href={NewRowAction tableName}>Add Row</a>
            </div>|]
                where
                    contextMenuId = "context-menu-column-" <> tshow id
                    id = (cs (fromMaybe "" (get #fieldValue (fromJust (headMay fields)))))

            renderField id fields DynamicField { .. } = if (tshow targetName) == (tshow fieldName) && targetId == id
                then [hsx|<td>
                <form method="POST" action={UpdateRowAction}>
                    <input type="text" name={fieldName} value={"'" <> fromMaybe "" fieldValue <> "'"}/>
                    {forEach fields renderValue}
                    <input type="hidden" name="tableName" value={tableName}/>
                    <button type="submit" class="d-none">Edit</button>
                </form></td>|]
                else [hsx|<td><span data-fieldname={fieldName}><a class="no-link" href={EditRowValueAction tableName (cs fieldName) id}>{fieldValue}</a></span></td>|]
            renderValue DynamicField { .. } = [hsx|<input type="hidden" name={fieldName} value={"'" <> fromMaybe "" fieldValue <> "'"}/>|]
            columnNames = map (get #fieldName) (fromMaybe [] (head rows))